class StageGear::ProjectorRental < ApplicationRecord
  belongs_to :client
  belongs_to :projector

  has_one_attached :purchase_order

  has_one :check_in, dependent: :nullify

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :status, presence: true

  validate :start_date_must_be_in_future, on: :create
  validate :projector_not_already_rented, on: %i[create update]
  validate :start_date_is_monday
  validate :end_date_is_monday

  serialize :address, Hash

  enum status: %i[pending reserved active completed cancelled]

  require "shippo"

  def new_rental_with_projector(projector_rental_params)
    projector_type = projector_rental_params[:projector_type]
    start_date = projector_rental_params[:start_date]
    end_date = projector_rental_params[:end_date]

    available_projectors =
      StageGear::Projector.where(
        projector_type: StageGear::ProjectorType.find_by(name: projector_type.capitalize())
      ).available_on_dates(start_date, end_date)

    best_available_projector = available_projectors.first
    raise "No Available Projectors of that type for selected dates" unless best_available_projector

    projector_rental_params[:projector_id] = best_available_projector.id
    projector_rental_params[:address] ||= {}
    projector_rental_params[:address][:country] = "US"

    new(projector_rental_params)
  end

  def order_shipped
    self.update(status: 2)
    self.projector.update(status: :rented_out)
  end

  def order_confirmation
    self.update(status: 1)
    self.projector.update(status: :reserved)
    projector_rental = self
    response =
      projector_rental.create_shippo_request(projector_rental.client, projector_rental.projector)
    if response.status == "SUCCESS"
      pp(response)
      self.update(shippo_object_id: response.object.id)
    else
      render json: response.status, status: :unprocessable_entity
    end
  end

  def create_shippo_request(user, projector)
    shipment_address = {}

    if self.address.present?
      shipment_address = self.address
      shipment_address.merge!(phone_number: "")
    elsif user.address.present?
      shipment_address = user.address
      shipment_address.merge!(street_address: user.address.line1)
      shipment_address.merge!(phone_number: user.phone.number)
    else
      raise "No Address Available for Shipment Creation"
    end

    params = {
      async: false,
      address_from: {
        name: "Stage Gear LLC",
        company: "Stage Gear LLC",
        street1: "402 W. Bedford Suite 101",
        street2: "",
        city: "Fresno",
        state: "CA",
        zip: "93711",
        country: "US",
        phone: ""
      },
      address_to: {
        name: shipment_address["first_name"] + " " + shipment_address["last_name"],
        company: shipment_address["organization"],
        street1: shipment_address["street_address"],
        city: shipment_address["city"],
        state: shipment_address["state"],
        zip: shipment_address["postal_code"],
        country: "US",
        phone: shipment_address["phone_number"],
        email: shipment_address["email"]
      },
      parcels: {
        length: projector.projector_type.length,
        width: projector.projector_type.width,
        height: projector.projector_type.height,
        distance_unit: :in,
        weight: projector.projector_type.weight,
        mass_unit: :lb
      }
    }

    # Make our API call
    shipment = Shippo::Shipment.create(params)

    shipment
  end

  def shippo_order_page
    return "https://apps.goshippo.com/orders/#{self.shippo_object_id}"
  end

  def shippo_order_object
    transaction = Shippo::Shipment.get(self.shippo_object_id)
    transaction
  end

  def tracking_status
    self.shippo_order_object.tracking_status
  end

  def rental_length
    (end_date - start_date) / 7.0
  end

  private

  def start_date_must_be_in_future
    if start_date && start_date < 7.days.from_now
      errors.add(:start_date, "must be more than 7 days away")
    end
  end

  def projector_not_already_rented
    if status == "pending" && projector && projector_already_rented?
      errors.add(:projector, "is already rented during this time period")
    end
  end

  def projector_already_rented?
    projector.projector_rentals.any? do |r|
      r.start_date <= end_date && r.end_date >= end_date ||
        r.start_date <= start_date && r.end_date >= start_date ||
        start_date < r.start_date && end_date > r.end_date
    end
  end

  def start_date_is_monday
    errors.add(:start_date, "must be a Monday") unless start_date.present? && start_date.monday?
  end

  def end_date_is_monday
    errors.add(:end_date, "must be a Monday") unless end_date.present? && end_date.monday?
  end
end
