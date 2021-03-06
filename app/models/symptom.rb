class Symptom < ApplicationRecord
  belongs_to :symptom_group
  has_many :check_in_symptoms, dependent: :destroy
  has_many :supplements, through: :effects
  has_many :effects

  validates :name, :description, :symptom_group, presence: true

  delegate :points, :icon, to: :symptom_group

  class << self
    def for_user(user, limit: 3, category: nil, after_date: nil)
      joins(:symptom_group, check_in_symptoms: :check_in)
        .where(check_in_symptoms: { check_ins: { user_id: user.id } })
        .where('check_ins.created_at > ?', after_date.present? ? after_date : Date.parse('2016-01-01'))
        .where(symptom_groups: { category: SymptomGroup.normalize_categories(category) })
        .group('symptoms.id')
        .order('count(check_in_symptoms.check_in_id) DESC')
        .limit(limit)
    end
  end
end
