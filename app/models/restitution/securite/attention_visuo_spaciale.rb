# frozen_string_literal: true

module Restitution
  class Securite
    class AttentionVisuoSpaciale
      attr_reader :evenements_situation

      def initialize(evenements_situation, _)
        @evenements_situation = evenements_situation
      end

      def calcule
        identification = evenements_situation
                         .select(&:est_un_danger_bien_identifie?)
                         .find(&:danger_visuo_spatial?)
        return ::Competence::NIVEAU_INDETERMINE if identification.blank?

        activation_aide1 = MetriquesHelper.activation_aide1(evenements_situation)
        if activation_aide1.present? && activation_aide1.date < identification.date
          return ::Competence::APTE_AVEC_AIDE
        end

        ::Competence::APTE
      end
    end
  end
end
