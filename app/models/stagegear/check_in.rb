class StageGear::CheckIn < ApplicationRecord
  belongs_to :projector_rental, optional: true

  validates :projector_rental_id, presence: true, on: :create
  validates :return_date, presence: true

  has_many_attached :images

  enum result: %i[accepted maintenance]

  before_save :update_projector_and_projector_rental_status
  before_save :update_late_return_status

  validate :return_date_cannot_be_in_the_future

  validates :damage_fees, presence: true, if: :damage_description
  validates :late_fee, presence: true, if: :late_return

  private

  def update_projector_and_projector_rental_status
    self.projector_rental.update(status: :completed)

    if self.result == 0
      self.projector_rental.projector.update(status: :available)
    else
      self.projector_rental.projector.update(status: :maintenance)
    end
  end

  def update_late_return_status
    self.late_return = self.return_date > self.projector_rental.end_date
  end

  def return_date_cannot_be_in_the_future
    if return_date.present? && return_date > Date.today
      errors.add(:return_date, "can't be in the future")
    end
  end
end
