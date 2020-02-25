# frozen_string_literal: true

module Restitution
  class Maintenance
    class TempsMotsFrancais < Restitution::Metriques::Base
      def calcule(evenements_situation, _)
        Restitution::MetriquesHelper.temps_action(evenements_situation,
                                                  :identification_mot_francais_correct?,
                                                  &:type_mot_francais?)
      end
    end
  end
end
