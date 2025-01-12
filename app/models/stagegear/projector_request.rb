class StageGear::ProjectorRequest
  include ActiveModel::API

  attr_accessor :projector_type,
                :start_date,
                :end_date,
                :first_name,
                :last_name,
                :organization,
                :email,
                :street_address,
                :city,
                :state,
                :postal_code,
                :payment_type,
                :coi,
                :drivers_license,
                :purchase_order,
                :success_url,
                :cancel_url

  def create_or_find_client
    Client.find_or_create_by!(email: email) do |c|
      c.assign_attributes(
        first_name: first_name,
        last_name: last_name,
        organization: organization,
        password: "password"
      )
    end
  end

  def find_best_projector
    type = StageGear::ProjectorType.find_by(name: projector_type.capitalize)
    available_projectors =
      StageGear::Projector.where(projector_type: type).available_on_dates(start_date, end_date)
    available_projectors.first
  end

  def create_rental(client, projector)
    rental =
      StageGear::ProjectorRental.new(
        start_date: Date.strptime(start_date),
        end_date: Date.strptime(end_date),
        client: client,
        projector: projector,
        address: {
          "first_name" => first_name,
          "last_name" => last_name,
          "organization" => organization,
          "street_address" => street_address,
          "city" => city,
          "state" => state,
          "postal_code" => postal_code,
          "country" => "US",
          "email" => email
        }
      )
    rental.purchase_order << purchase_order if purchase_order.present?
    rental
  end
end
