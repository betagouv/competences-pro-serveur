# frozen_string_literal: true

class Campagne < ApplicationRecord
  PARCOURS = {
    complet: %i[
      bienvenue
      maintenance
      livraison
      tri
      securite
      objets_trouves
      inventaire
    ],
    competences_de_base: %i[
      maintenance
      livraison
      objets_trouves
    ]
  }.freeze

  has_many :situations_configurations, -> { order(position: :asc) }, dependent: :destroy
  belongs_to :questionnaire, optional: true
  belongs_to :compte
  default_scope { order(created_at: :asc) }

  validates :libelle, presence: true
  validates :code, presence: true, uniqueness: true

  accepts_nested_attributes_for :situations_configurations, allow_destroy: true
  accepts_nested_attributes_for :compte

  attr_accessor :initialise_situations, :modele_parcours

  before_create :initialise_situations_par_defaut, if: :initialise_situations

  def display_name
    libelle
  end

  def questionnaire_pour(situation)
    situations_configurations.find_by(situation: situation)&.questionnaire_utile
  end

  private

  def initialise_situations_par_defaut
    self.modele_parcours ||= :complet
    PARCOURS[modele_parcours.to_sym].each do |nom_technique|
      situation = Situation.find_by nom_technique: nom_technique
      situations_configurations.build situation: situation unless situation.nil?
    end
  end
end
