# frozen_string_literal: true

module Restitution
  class Maintenance < AvecEntrainement
    def initialize(campagne, evenements)
      evenements = evenements.map { |e| EvenementMaintenanceDecorator.new e }
      super(campagne, evenements)
    end

    Restitution::Metriques::MAINTENANCE.keys.each do |metrique|
      define_method metrique do
        Metriques::MAINTENANCE[metrique]
          .new(evenements_situation)
          .calcule
      end
    end

    def persiste
      metriques = Metriques::MAINTENANCE.keys.each_with_object({}) do |nom_metrique, memo|
        memo[nom_metrique] = public_send(nom_metrique)
      end
      partie.update(metriques: metriques)
    end
  end
end
