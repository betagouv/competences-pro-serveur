# frozen_string_literal: true

require_relative '../../decorators/evenement_maintenance'

module Restitution
  class Maintenance < AvecEntrainement
    METRIQUES = {
      'temps_total' => {
        'type' => :nombre,
        'instance' => Base::TempsTotal.new
      },
      'temps_entrainement' => {
        'type' => :nombre,
        'instance' => AvecEntrainement::TempsEntrainement.new
      },
      'nombre_bonnes_reponses_francais' => {
        'type' => :nombre,
        'instance' => Maintenance::NombreBonnesReponsesMotFrancais.new
      },
      'nombre_bonnes_reponses_non_mot' => {
        'type' => :nombre,
        'instance' => Maintenance::NombreBonnesReponsesNonMot.new
      },
      'nombre_non_reponses' => {
        'type' => :nombre,
        'instance' => Maintenance::NombreNonReponses.new
      },
      'temps_moyen_mots_francais' => {
        'type' => :nombre,
        'instance' => Metriques::Moyenne.new(Maintenance::TempsMotsFrancais.new)
      },
      'temps_moyen_non_mots' => {
        'type' => :nombre,
        'instance' => Metriques::Moyenne.new(Maintenance::TempsNonMots.new)
      },
      'score_vocabulaire' => {
        'type' => :nombre,
        'instance' => Maintenance::ScoreVocabulaire.new
      }
    }.freeze

    def initialize(campagne, evenements)
      evenements = evenements.map { |e| EvenementMaintenance.new e }
      super(campagne, evenements)
    end

    METRIQUES.keys.each do |metrique|
      define_method metrique do
        METRIQUES[metrique]['instance']
          .calcule(evenements_situation, evenements_entrainement)
      end
    end

    def persiste
      metriques = METRIQUES.keys.each_with_object({}) do |nom_metrique, memo|
        memo[nom_metrique] = public_send(nom_metrique)
      end
      partie.update(metriques: metriques)
    end

    def score
      partie.cote_z_metriques['score_vocabulaire']
    end

    def competences_de_base
      calcule_competences(
        ::Competence::VOCABULAIRE => Maintenance::Vocabulaire
      )
    end
  end
end
