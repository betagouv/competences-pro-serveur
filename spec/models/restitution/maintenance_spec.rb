# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Maintenance do
  let(:evenements) { [] }
  let(:campagne) { Campagne.new }
  let(:restitution) { described_class.new campagne, evenements }

  describe '#persiste' do
    context "persiste l'ensemble des données de maintenance" do
      let(:situation) { create :situation_maintenance }
      let(:evaluation) { create :evaluation, campagne: campagne }
      let!(:partie) { create :partie, situation: situation, evaluation: evaluation }
      let(:evenements) do
        [build(:evenement_demarrage)]
      end

      it do
        expect(restitution).to receive(:nombre_non_reponses).and_return 2
        expect(restitution).to receive(:nombre_bonnes_reponses_non_mot).and_return 20
        expect(restitution).to receive(:temps_moyen_mots_francais).and_return 0.789
        expect(restitution).to receive(:temps_moyen_non_mots).and_return 1.5
        restitution.persiste
        partie.reload
        expect(partie.metriques['nombre_non_reponses']).to eq 2
        expect(partie.metriques['nombre_bonnes_reponses_non_mot']).to eq 20
        expect(partie.metriques['temps_moyen_mots_francais']).to eq 0.789
        expect(partie.metriques['temps_moyen_non_mots']).to eq 1.5
      end
    end
  end

  describe '#score' do
    def score_pour(nombre_francais, temps_francais, nombre_non_mots, temps_non_mots)
      allow(restitution).to receive(:temps_moyen_normalise)
        .and_return(temps_francais, temps_non_mots)
      allow(restitution).to receive_messages(nombre_bonnes_reponses_francais: nombre_francais,
                                             nombre_bonnes_reponses_non_mot: nombre_non_mots)
      restitution.score
    end

    it { expect(score_pour(0, nil, 0, nil)).to eq(nil) }
    it { expect(score_pour(0, nil, 5, 1)).to eq(5 / 1) }
    it { expect(score_pour(2, 1.5, 0, nil)).to eq(2 / 1.5) }
    it { expect(score_pour(2, 1.5, 5, 3)).to eq(2 / 1.5 + 5 / 3) }
  end

  describe '#temps_moyen_normalise' do
    context 'calcule le temps moyen normalises pour les mots francais' do
      let(:situation) { create :situation_maintenance }
      let(:evaluation) { create :evaluation, campagne: campagne }
      let!(:partie) { create :partie, situation: situation, evaluation: evaluation }
      let(:mock_metrique_temps) { double }

      it do
        allow(partie).to receive(:moyenne_metrique)
          .with(:temps_moyen_mots_francais).and_return(2.7)
        allow(partie).to receive(:ecart_type_metrique)
          .with(:temps_moyen_mots_francais).and_return(0.5)
        allow(restitution).to receive(:partie).and_return(partie)

        expect(mock_metrique_temps).to receive(:calcule).and_return([2.7, 3.7, 3.8])
        temps_moyen_normalise = restitution.temps_moyen_normalise(:temps_moyen_mots_francais,
                                                                  mock_metrique_temps)
        expect(temps_moyen_normalise).to eq((2.7 + 3.7) / 2.0)
      end
    end
  end
end
