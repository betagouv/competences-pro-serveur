# frozen_string_literal: true

module Restitution
  module Illettrisme
    class NombreReponses < Restitution::Metriques::Base
      def calcule(evenements, metacompetence)
        evenements.select do |evenement|
          evenement.metacompetence == metacompetence &&
            evenement.nom == 'reponse'
        end.count
      end
    end
  end
end
