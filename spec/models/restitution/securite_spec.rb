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

  describe '#nombre_retours_non_dangers_identifies' do
    context 'sans évenement' do
      let(:evenements) { [] }
      it { expect(restitution.nombre_retours_non_dangers_identifies).to eq 0 }
    end

    context 'avec un retour sur une zone de non danger identifiée' do
      let(:evenements) do
        [build(:evenement_identification_danger,
               donnees: { reponse: 'oui', zone: 'zone-voiture-rouge' }),
         build(:evenement_identification_danger,
               donnees: { reponse: 'non', zone: 'zone-voiture-rouge' })]
      end
      it { expect(restitution.nombre_retours_non_dangers_identifies).to eq 1 }
    end

    context 'avec des zones de non danger identifiées mais sans retour' do
      let(:evenements) do
        [build(:evenement_identification_danger,
               donnees: { reponse: 'oui', zone: 'zone-voiture-rouge' }),
         build(:evenement_identification_danger,
               donnees: { reponse: 'oui', zone: 'zone-voiture-verte' })]
      end
      it { expect(restitution.nombre_retours_non_dangers_identifies).to eq 0 }
    end
  end
end
