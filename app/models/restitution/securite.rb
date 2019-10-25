# frozen_string_literal: true

module Restitution
  class Securite < Base
    BONNE_QUALIFICATION = 'bonne'
    IDENTIFICATION_POSITIVE = 'oui'
    DANGERS_TOTAL = 5
    DANGER_VISUO_SPATIAL = 'signalisation'

    EVENEMENT = {
      QUALIFICATION_DANGER: 'qualificationDanger',
      IDENTIFICATION_DANGER: 'identificationDanger',
      ACTIVATION_AIDE_1: 'activationAide',
      DEMARRAGE: 'demarrage'
    }.freeze

    def termine?
      qualifications_par_danger.count == DANGERS_TOTAL
    end

    def temps_entrainement
      evenements_entrainement.last.date - evenements_entrainement.first.date
    end

    def nombre_bien_qualifies
      qualifications_finales = qualifications_par_danger.map do |_danger, qualifications|
        qualifications.max_by(&:created_at)
      end
      qualifications_finales.count { |e| bonne_reponse?(e) }
    end

    def nombre_dangers_identifies
      dangers_identifies.count
    end

    def nombre_retours_deja_qualifies
      qualifications_par_danger.inject(0) do |memo, (_danger, qualifications)|
        memo + qualifications.count - 1
      end
    end

    def nombre_dangers_identifies_avant_aide_1
      return nombre_dangers_identifies if activation_aide1.blank?

      dangers_identifies_tries = dangers_identifies.partition do |danger|
        danger.date < activation_aide1.date
      end
      dangers_identifies_tries.first.length
    end

    def temps_identification_premier_danger
      return 0 if premiere_identification_vrai_danger.blank?

      premiere_identification_vrai_danger.date - demarrage.date
    end

    def attention_visuo_spatiale
      identification = dangers_identifies.find { |e| e.donnees['danger'] == DANGER_VISUO_SPATIAL }
      return ::Competence::NIVEAU_INDETERMINE if identification.blank?

      if activation_aide1.present? && activation_aide1.date < identification.date
        return ::Competence::APTE_AVEC_AIDE
      end

      ::Competence::APTE
    end

    private

    def bonne_reponse?(evenement)
      evenement.donnees['reponse'] == BONNE_QUALIFICATION
    end

    def qualifications_par_danger
      qualifications_dangers = evenements_situation.select do |e|
        e.nom == EVENEMENT[:QUALIFICATION_DANGER]
      end
      qualifications_dangers.group_by { |e| e.donnees['danger'] }
    end

    def dangers_identifies
      evenements_situation.select { |e| est_un_danger_identifie?(e) }
    end

    def est_un_danger_identifie?(evenement)
      evenement.nom == EVENEMENT[:IDENTIFICATION_DANGER] &&
        evenement.donnees['reponse'] == IDENTIFICATION_POSITIVE &&
        evenement.donnees['danger'].present?
    end

    def premier_evenement_du_nom(evenements, nom_evenement)
      evenements.find { |e| e.nom == nom_evenement }
    end

    def demarrage
      @demarrage ||= premier_evenement_du_nom(evenements, EVENEMENT[:DEMARRAGE])
    end

    def evenements_chronologiques
      @evenements_chronologiques ||= evenements.sort_by(&:date)
    end

    def evenements_situation
      @evenements_situation ||= evenements_chronologiques.select { |e| e.date >= demarrage.date }
    end

    def evenements_entrainement
      @evenements_entrainement ||= evenements_chronologiques.take_while do |evenement|
        evenement.nom != EVENEMENT[:DEMARRAGE]
      end
    end

    def premiere_identification_vrai_danger
      @premiere_identification_vrai_danger ||= evenements_situation.find do |e|
        e.nom == EVENEMENT[:IDENTIFICATION_DANGER] &&
          e.donnees['danger'].present?
      end
    end

    def activation_aide1
      @activation_aide1 ||= premier_evenement_du_nom(
        evenements_situation,
        EVENEMENT[:ACTIVATION_AIDE_1]
      )
    end
  end
end
