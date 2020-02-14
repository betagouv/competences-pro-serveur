# frozen_string_literal: true

module Restitution
  class Metriques
    SECURITE = {
      'temps_total' => Securite,
      'temps_entrainement' => Securite,
      'nombre_dangers_bien_identifies' => Securite::NombreDangersBienIdentifies,
      'nombre_dangers_bien_identifies_avant_aide_1' =>
                                          Securite::NombreDangersBienIdentifiesAvantAide1,
      'nombre_dangers_mal_identifies' => Securite::NombreDangersMalIdentifies,
      'attention_visuo_spatiale' => Securite::AttentionVisuoSpaciale,
      'temps_bonnes_qualifications_dangers' => Securite::TempsBonnesQualificationsDangers,
      'temps_recherche_zones_dangers' => Securite::TempsRechercheZonesDangers,
      'temps_total_ouverture_zones_dangers' => Securite::TempsTotalOuvertureZonesDangers,
      'nombre_reouverture_zone_sans_danger' => Securite,
      'nombre_bien_qualifies' => Securite::NombreDangersBienQualifies,
      'nombre_retours_deja_qualifies' => Securite::NombreRetoursDejaQualifies,
      'delai_ouvertures_zones_dangers' => Securite,
      'delai_moyen_ouvertures_zones_dangers' => Securite,
      'nombre_rejoue_consigne' => Securite
    }.freeze

    MAINTENANCE = {
      'nombre_bonnes_reponses_mot_français' => Maintenance::NombreBonnesReponsesMotFrancais,
      'nombre_non_reponses' => Maintenance::NombreNonReponses,
      'nombre_erreurs' => Maintenance::NombreErreurs,
      'temps_moyen_non_mots' => Maintenance::TempsMoyenNonMots
    }.freeze
  end
end
