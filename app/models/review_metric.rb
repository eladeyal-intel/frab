class ReviewMetric < ApplicationRecord
  belongs_to :conference
  has_many :review_score, dependent: :destroy
  
  validates :name, presence: true, uniqueness: { scope: :conference }
end
