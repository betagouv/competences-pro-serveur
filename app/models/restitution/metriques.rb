# frozen_string_literal: true

module Restitution
  class Metriques
    REGLES_SECURITE = {
      'temps_bonnes_qualifications_dangers' => Securite::TempsBonnesQualificationsDangers,
      'temps_recherche_zones_dangers' => Securite::TempsRechercheZonesDangers,
      'temps_total_ouverture_zones_dangers' => Securite::TempsTotalOuvertureZonesDangers
    }.freeze

    SECURITE = %i[
      nombre_reouverture_zone_sans_danger nombre_bien_qualifies
      nombre_dangers_bien_identifies nombre_retours_deja_qualifies
      nombre_dangers_bien_identifies_avant_aide_1 attention_visuo_spatiale
      delai_ouvertures_zones_dangers delai_moyen_ouvertures_zones_dangers
      temps_entrainement temps_total nombre_rejoue_consigne nombre_danger_mal_identifies
    ].freeze
  end
end
