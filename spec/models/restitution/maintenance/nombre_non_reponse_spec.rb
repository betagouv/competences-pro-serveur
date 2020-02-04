# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Maintenance::NombreNonReponses do
  let(:campagne) { Campagne.new }
  let(:restitution) { Restitution::Maintenance.new campagne, evenements }

  describe '#metrique nombre_non_reponses' do
    context "aucun événement d'identification" do
      let(:evenements) do
        [
          build(:evenement_demarrage)
        ]
      end
      it { expect(restitution.metrique('nombre_non_reponses')).to eq 0 }
    end

    context 'avec une non réponse' do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_identification_mot, :non_reponse)
        ]
      end
      it { expect(restitution.metrique('nombre_non_reponses')).to eq 1 }
    end

    context 'avec une réponse' do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_identification_mot, :bon)
        ]
      end
      it { expect(restitution.metrique('nombre_non_reponses')).to eq 0 }
    end
  end
end
