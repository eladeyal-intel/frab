class ReviewMetric < ApplicationRecord
  belongs_to :conference
  
  validates :name, presence: true, uniqueness: { scope: :conference }
end
