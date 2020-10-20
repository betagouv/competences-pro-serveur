# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Standardisateur do
  let(:situation)  { create :situation_securite }
  let(:evaluation) { create :evaluation }
  let(:partie1) do
    create :partie,
           situation: situation,
           evaluation: evaluation,
           metriques: {
             test_metrique: 1,
             test_metrique_tableau: [1, 2],
             test_chaine: 'test1'
           }
  end
  let(:partie2) do
    create :partie,
           situation: situation,
           evaluation: evaluation,
           metriques: {
             test_metrique: 0,
             test_metrique_tableau: [2, 3],
             test_chaine: 'test2'
           }
  end

  let(:partie3) do
    create :partie,
           situation: situation,
           evaluation: evaluation,
           metriques: {
             test_metrique: 2,
             test_metrique_tableau: [2, 3],
             test_chaine: 'test2'
           }
  end

  let(:restitution) { FabriqueRestitution.instancie(partie1.id) }

  before do
    # pour que la restitution puisse retrouver la partie !
    create(:evenement_demarrage, partie: partie1)
  end

  context '#moyennes_metriques' do
    context "calcule les moyennes pour l'ensemble des metriques" do
      before { [partie1, partie2, partie3] }

      it do
        expect(restitution.moyennes_metriques).to eql('test_metrique' => 1.0)
      end
    end
  end

  context '#ecarts_types_metriques' do
    context "calcule les écarts types pour l'ensemble des metriques" do
      before { [partie1, partie2, partie3] }

      it do
        expect(restitution.ecarts_types_metriques).to eql('test_metrique' => 0.816496580927726)
      end
    end
  end

  context '#cote_z_metriques' do
    context 'calcule le score standardisé (cote_z)' do
      before { [partie1, partie2, partie3] }

      it do
        expect(restitution.cote_z_metriques).to eql('test_chaine' => nil,
                                                    'test_metrique' => 0.0,
                                                    'test_metrique_tableau' => nil)
      end
    end

    context "lorsque la partie courante n'est pas terminée" do
      before { [partie1, partie2, partie3] }

      it do
        partie1.update(metriques: {})
        expect(restitution.cote_z_metriques).to eql({})
      end
    end

    context "lorsque l'écart type est nul" do
      it do
        expect(restitution.cote_z_metriques).to eql('test_chaine' => nil,
                                                    'test_metrique' => 0,
                                                    'test_metrique_tableau' => nil)
      end
    end
  end
end
