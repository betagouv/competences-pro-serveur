# frozen_string_literal: true

module Restitution
  module Illettrisme
    class InterpreteurNiveau2
      def initialize(scores)
        @interpreteur_score = InterpreteurScores.new(scores)
      end

      def interpretations(categorie)
        competences = if categorie == :litteratie
                        Restitution::ScoresNiveau1::METACOMPETENCES_LITTERATIE
                      else
                        Restitution::ScoresNiveau1::METACOMPETENCES_NUMERATIE
                      end
        @interpreteur_score.interpretations(competences)
      end
    end
  end
end
