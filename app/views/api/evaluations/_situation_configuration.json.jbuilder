# frozen_string_literal: true

json.id situation_configuration.situation_id
json.libelle situation_configuration.libelle
json.nom_technique situation_configuration.nom_technique
json.questionnaire_id situation_configuration.questionnaire_utile&.id
json.questionnaire_entrainement_id situation_configuration.questionnaire_entrainement_id
