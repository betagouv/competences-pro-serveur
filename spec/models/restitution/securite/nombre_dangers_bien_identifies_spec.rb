# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Securite::NombreDangersBienIdentifies do
  let(:campagne) { Campagne.new }
  let(:restitution) { Restitution::Securite.new campagne, evenements }

  describe '#nombre_dangers_bien_identifies' do
    context 'sans évenement' do
      let(:evenements) { [] }
      it { expect(restitution.nombre_dangers_bien_identifies).to eq 0 }
    end

    context 'avec bonne identification' do
      let(:evenements) do
        [build(:evenement_demarrage),
         build(:evenement_identification_danger, donnees: { reponse: 'oui', danger: 'danger' })]
      end
      it { expect(restitution.nombre_dangers_bien_identifies).to eq 1 }
    end

    context 'ignore les réponses négatives' do
      let(:evenements) do
        [build(:evenement_demarrage),
         build(:evenement_identification_danger, donnees: { reponse: 'non' })]
      end
      it { expect(restitution.nombre_dangers_bien_identifies).to eq 0 }
    end

    context 'ignore les identifications de zone sans danger' do
      let(:evenements) do
        [build(:evenement_demarrage),
         build(:evenement_identification_danger, donnees: { reponse: 'oui' })]
      end
      it { expect(restitution.nombre_dangers_bien_identifies).to eq 0 }
    end
  end
end
