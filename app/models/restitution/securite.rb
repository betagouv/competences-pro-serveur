# frozen_string_literal: true

module Restitution
  class Securite < AvecEntrainement
    ZONES_DANGER = %w[bouche-egout camion casque escabeau signalisation].freeze

    def initialize(campagne, evenements)
      evenements = evenements.map { |e| EvenementSecuriteDecorator.new e }
      super(campagne, evenements)
    end

    def termine?
      super ||
        SecuriteHelper.qualifications_par_danger(evenements_situation).count == ZONES_DANGER.count
    end

    def persiste
      metriques = Metriques::SECURITE.keys.each_with_object({}) do |methode, memo|
        memo[methode] = public_send(methode)
      end
      partie.update(metriques: metriques)
    end

    def nombre_dangers_bien_identifies
      Metriques::SECURITE['nombre_dangers_bien_identifies'].new(evenements_situation).calcule
    end

    def nombre_dangers_mal_identifies
      Metriques::SECURITE['nombre_dangers_mal_identifies'].new(evenements_situation).calcule
    end

    def nombre_bien_qualifies
      Metriques::SECURITE['nombre_bien_qualifies'].new(evenements_situation).calcule
    end

    def nombre_retours_deja_qualifies
      Metriques::SECURITE['nombre_retours_deja_qualifies'].new(evenements_situation).calcule
    end

    def nombre_dangers_bien_identifies_avant_aide_1
      Metriques::SECURITE['nombre_dangers_bien_identifies_avant_aide_1']
        .new(evenements_situation)
        .calcule
    end

    def attention_visuo_spatiale
      Metriques::SECURITE['attention_visuo_spatiale'].new(evenements_situation).calcule
    end

    def nombre_reouverture_zones_sans_danger
      Metriques::SECURITE['nombre_reouverture_zones_sans_danger'].new(evenements_situation).calcule
    end

    def delai_ouvertures_zones_dangers
      temps_entre_evenements do |e|
        e.demarrage? || e.qualification_danger? || e.ouverture_zone_danger?
      end
    end

    def temps_recherche_zones_dangers
      Metriques::SECURITE['temps_recherche_zones_dangers'].new(evenements_situation).calcule
    end

    def temps_bonnes_qualifications_dangers
      Metriques::SECURITE['temps_bonnes_qualifications_dangers'].new(evenements_situation).calcule
    end

    def temps_total_ouverture_zones_dangers
      Metriques::SECURITE['temps_total_ouverture_zones_dangers'].new(evenements_situation).calcule
    end

    def delai_moyen_ouvertures_zones_dangers
      return nil if delai_ouvertures_zones_dangers.empty?

      delai_ouvertures_zones_dangers.sum / delai_ouvertures_zones_dangers.size
    end

    private

    def temps_entre_evenements
      evenements = evenements_situation.select { |e| yield e }
      MetriquesHelper.temps_entre_couples evenements
    end
  end
end
