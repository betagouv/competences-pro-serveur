# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Securite do
  let(:campagne) { Campagne.new }
  let(:restitution) { Restitution::Securite.new campagne, evenements }

  describe '#termine?' do
    context 'aucun danger qualifié' do
      let(:evenements) { [] }
      it { expect(restitution).to_not be_termine }
    end

    context 'tous les dangers qualifiés' do
      let(:evenements) do
        Array.new(Restitution::Securite::DANGERS_TOTAL) do |index|
          build(:evenement_qualification_danger, donnees: { danger: "danger-#{index}" })
        end
      end
      it { expect(restitution).to be_termine }
    end

    context 'ignore les requalifications de danger' do
      let(:evenements) do
        Array.new(Restitution::Securite::DANGERS_TOTAL) do
          build(:evenement_qualification_danger, donnees: { danger: 'danger' })
        end
      end
      it { expect(restitution).to_not be_termine }
    end
  end

  describe '#nombre_bien_qualifies' do
    context 'sans évenement' do
      let(:evenements) { [] }
      it { expect(restitution.nombre_bien_qualifies).to eq 0 }
    end

    context 'avec bonne qualification' do
      let(:evenements) { [build(:evenement_qualification_danger, :bon)] }
      it { expect(restitution.nombre_bien_qualifies).to eq 1 }
    end

    context 'ignore les mauvaises qualifications' do
      let(:evenements) { [build(:evenement_qualification_danger, :mauvais)] }
      it { expect(restitution.nombre_bien_qualifies).to eq 0 }
    end

    context 'prend en compte la requalification' do
      let(:evenements) do
        [build(:evenement_qualification_danger,
               donnees: { reponse: 'mauvais', danger: 'danger' }, created_at: 1.minute.ago),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'bonne', danger: 'danger' }, created_at: 2.minutes.ago)]
      end
      it { expect(restitution.nombre_bien_qualifies).to eq 0 }
    end
  end

  describe '#nombre_dangers_identifies' do
    context 'sans évenement' do
      let(:evenements) { [] }
      it { expect(restitution.nombre_dangers_identifies).to eq 0 }
    end

    context 'avec bonne identification' do
      let(:evenements) do
        [build(:evenement_identification_danger, donnees: { reponse: 'oui', danger: 'danger' })]
      end
      it { expect(restitution.nombre_dangers_identifies).to eq 1 }
    end

    context 'ignore les réponses négatives' do
      let(:evenements) do
        [build(:evenement_identification_danger, donnees: { reponse: 'non' })]
      end
      it { expect(restitution.nombre_dangers_identifies).to eq 0 }
    end

    context 'ignore les identifications de zone sans danger' do
      let(:evenements) do
        [build(:evenement_identification_danger, donnees: { reponse: 'oui' })]
      end
      it { expect(restitution.nombre_dangers_identifies).to eq 0 }
    end
  end

  describe '#nombre_retours_deja_qualifies' do
    context 'sans évenement' do
      let(:evenements) { [] }
      it { expect(restitution.nombre_retours_deja_qualifies).to eq 0 }
    end

    context 'deux qualifications du même danger' do
      let(:evenements) do
        [build(:evenement_qualification_danger,
               donnees: { reponse: 'mauvais', danger: 'danger' }),
         build(:evenement_qualification_danger,
               donnees: { reponse: 'bonne', danger: 'danger' })]
      end
      it { expect(restitution.nombre_retours_deja_qualifies).to eq 1 }
    end
  end

  describe '#nombre_dangers_identifies_avant_aide_1' do
    context 'sans évenement' do
      let(:evenements) { [] }
      it { expect(restitution.nombre_dangers_identifies_avant_aide_1).to eq 0 }
    end

    context "avec des dangers identifiés en ayant activé l'aide" do
      let(:evenements) do
        [build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: 'danger', nom: 'avant' },
               date: 3.minutes.ago),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: 'danger', nom: 'avant' },
               date: 2.minutes.ago),
         build(:activation_aide),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: 'danger' },
               date: 2.minutes.from_now)]
      end
      it { expect(restitution.nombre_dangers_identifies_avant_aide_1).to eq 2 }
    end

    context "avec des dangers identifiés aprés avoir activé l'aide" do
      let(:evenements) do
        [build(:activation_aide),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: 'danger' },
               date: 2.minutes.from_now)]
      end
      it { expect(restitution.nombre_dangers_identifies_avant_aide_1).to eq 0 }
    end

    context "avec un danger identifié sans avoir activé l'aide" do
      let(:evenements) do
        [build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: 'danger' },
               date: 2.minutes.from_now)]
      end
      it { expect(restitution.nombre_dangers_identifies_avant_aide_1).to eq 1 }
    end
  end

  describe '#temps_identification_premier_danger' do
    context 'sans évenement' do
      let(:evenements) { [] }
      it { expect(restitution.temps_identification_premier_danger).to eq 0 }
    end

    context 'avec des dangers identifiés' do
      let(:situation) { create :situation_securite }
      let(:evenements) do
        [build(:evenement_demarrage, situation: situation, date: Time.local(2019, 10, 9, 10, 0)),
         build(:evenement_identification_danger,
               donnees: { reponse: 'non', danger: 'danger' }, date: Time.local(2019, 10, 9, 10, 1)),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: 'danger' }, date: Time.local(2019, 10, 9, 10, 2))]
      end
      it { expect(restitution.temps_identification_premier_danger).to eq 60 }
    end

    context 'sans danger identifié' do
      let(:situation) { create :situation_securite }
      let(:evenements) do
        [build(:evenement_demarrage, situation: situation, date: 2.minutes.ago)]
      end
      it { expect(restitution.temps_identification_premier_danger).to eq 0 }
    end
  end

  describe '#attention_visuo_spatiale' do
    context 'sans évenement: indéterminé' do
      let(:evenements) { [] }
      it { expect(restitution.attention_visuo_spatiale).to eq Competence::NIVEAU_INDETERMINE }
    end

    context "avec identification du danger sans avoir activé l'aide" do
      let(:evenements) do
        [build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: Restitution::Securite::DANGER_VISUO_SPATIAL })]
      end

      it { expect(restitution.attention_visuo_spatiale).to eq Competence::APTE }
    end

    context "avec identification du danger après avoir activé l'aider" do
      let(:evenements) do
        [build(:activation_aide, date: 2.minutes.ago),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: Restitution::Securite::DANGER_VISUO_SPATIAL },
               date: 1.minute.ago)]
      end
      it { expect(restitution.attention_visuo_spatiale).to eq Competence::APTE_AVEC_AIDE }
    end

    context "avec identification du danger avant avoir activé l'aider" do
      let(:evenements) do
        [build(:evenement_identification_danger,
               donnees: { reponse: 'oui', danger: Restitution::Securite::DANGER_VISUO_SPATIAL },
               date: 2.minute.ago),
         build(:activation_aide, date: 1.minutes.ago)]
      end
      it { expect(restitution.attention_visuo_spatiale).to eq Competence::APTE }
    end
  end
end
