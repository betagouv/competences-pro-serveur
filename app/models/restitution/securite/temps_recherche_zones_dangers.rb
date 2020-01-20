# frozen_string_literal: true

module Restitution
  class Securite
    class TempsRechercheZonesDangers
      attr_reader :evenements_situation

      ZONES_DANGER = %w[bouche-egout casque escabeau camion signalisation].freeze

      def initialize(evenements_situation)
        @evenements_situation = evenements_situation
      end

      def calcule
        durees = []
        ZONES_DANGER.each do |danger|
          durees << duree_recherche(danger)
        end
        durees
      end

      private

      def duree_recherche(danger)
        date_evenement_precedent = nil
        evenements_situation.each do |e|
          if e.demarrage? || e.qualification_danger?
            date_evenement_precedent = e.date
          elsif e.donnees['danger'] == danger && e.ouverture_zone_danger?
            return e.date - date_evenement_precedent
          end
        end
        nil
      end
    end
  end
end
