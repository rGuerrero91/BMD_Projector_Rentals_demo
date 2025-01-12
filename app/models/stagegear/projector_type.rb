class StageGear::ProjectorType < ApplicationRecord
  has_many :projectors, dependent: :restrict_with_error

  validates :name, presence: true
  validates :length, presence: true
  validates :width, presence: true
  validates :height, presence: true
  validates :weight, presence: true
end
