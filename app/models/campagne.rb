# frozen_string_literal: true

class Campagne < ApplicationRecord
  has_many :situations_configurations, -> { order(position: :asc) }, dependent: :destroy
  belongs_to :questionnaire, optional: true
  belongs_to :compte
  belongs_to :parcours_type, optional: true
  default_scope { order(created_at: :asc) }

  validates :libelle, presence: true
  validates :code, presence: true, uniqueness: true

  accepts_nested_attributes_for :situations_configurations, allow_destroy: true
  accepts_nested_attributes_for :compte

  before_create :initialise_situations_par_defaut, if: :parcours_type_id

  def display_name
    libelle
  end

  def questionnaire_pour(situation)
    situations_configurations.find_by(situation: situation)&.questionnaire_utile
  end

  private

  def initialise_situations_par_defaut
    parcours_type.situations_configurations.each do |situation_configuration|
      situations_configurations.build situation_id: situation_configuration.situation_id
    end
  end
end
