class StageGear::Projector < ApplicationRecord
  belongs_to :projector_type

  has_many :projector_rentals, dependent: :destroy

  validates :status, presence: true
  validates :unit_number, presence: true
  validates :serial_number, presence: true

  has_many_attached :images
  has_one_attached :thumbnail_image

  enum status: %i[available reserved rented_out maintenance]

  def self.available_on_dates(start_date, end_date)
    self.where.not(
      id:
        StageGear::ProjectorRental.where(
          "start_date <= ? AND end_date >= ? OR start_date <= ? AND end_date >= ? OR start_date > ? AND end_date < ?",
          start_date,
          start_date,
          end_date,
          end_date,
          start_date,
          end_date
        ).pluck(:projector_id)
    )
  end

  def measurements
    self.projector_type.to_json
  end

  def self.available
    # Query for projectors that do not have any associated projector_rentals
    # with a start_date in the future or a status of 'rented'
    StageGear::Projector
      .left_outer_joins(:projector_rentals)
      .where("projector_rentals.start_date > ? OR projector_rentals.status != ?", Date.today, 2)
      .group(:id)
      .having("COUNT(projector_rentals.id) = 0")
  end
end
