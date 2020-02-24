# frozen_string_literal: true

module Restitution
  class MetriquesHelper
    EVENEMENT = {
      ACTIVATION_AIDE_1: 'activationAide'
    }.freeze

    class << self
      def premier_evenement_du_nom(evenements, nom_evenement)
        evenements.find { |e| e.nom == nom_evenement }
      end

      def temps_entre_couples(evenements)
        les_temps = []
        evenements.each_slice(2) do |e1, e2|
          next if e2.blank?

          les_temps << e2.date - e1.date
        end
        les_temps
      end

      def activation_aide1(evenements)
        premier_evenement_du_nom(evenements, EVENEMENT[:ACTIVATION_AIDE_1])
      end

      def temps_action(evenements, filtre_reponse, &filtre_evenements)
        temps_entre_couples(
          apparitions_et_reponses(evenements, filtre_reponse, &filtre_evenements)
        )
      end

      private

      def apparitions_et_reponses(evenements, filtre_reponse, &filtre_evenements)
        evenements_retenus = []
        evenements.select(&filtre_evenements).each_slice(2) do |apparition, reponse|
          next unless reponse&.send(filtre_reponse)

          evenements_retenus << apparition << reponse
        end
        evenements_retenus
      end
    end
  end
end
