class ReviewMetric < ApplicationRecord
  belongs_to :conference
  has_many :review_score, dependent: :destroy
  has_many :average_review_score, dependent: :destroy
  
  has_paper_trail meta: { associated_id: :conference_id, associated_type: 'Conference' }

  def to_s
    "#{model_name.human}: #{name}"
  end
  
  def safe_name
    name.parameterize.gsub(%r{[^a-z0-9]}, '_')
  end
  
  validates :name, presence: true, uniqueness: { scope: :conference }
  validates_each :name do |record, attr, value|
    proposed_identifier=record.safe_name
    if record.safe_name.blank? or not record.safe_name.match(/^[a-z]/)
      record.errors.add(attr, :invalid)
    elsif record.conference.review_metrics.where.not(id: record.id).map(&:safe_name).include? record.safe_name
      record.errors.add(attr, :taken)
    end
  end
end
