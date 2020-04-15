# frozen_string_literal: true

module Restitution
  class Livraison
    class TempsBonnesReponses < Restitution::Metriques::Base
      def calcule(evenements, metacompetence)
        Restitution::MetriquesHelper.temps_action(evenements, :bonne_reponse?) do |evenement|
          evenement.metacompetence == metacompetence
        end
      end
    end
  end
end
