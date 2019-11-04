# frozen_string_literal: true

require 'rails_helper'

describe 'Evaluation API', type: :request do
  describe 'POST /evaluations' do
    let!(:campagne_ete19) { create :campagne, code: 'ETE19' }

    context 'Quand une requête est valide' do
      let(:payload_valide_avec_campagne) { { nom: 'Roger', code_campagne: 'ETE19' } }
      before { post '/api/evaluations', params: payload_valide_avec_campagne }
      it { expect(Evaluation.last.campagne).to eq campagne_ete19 }
    end

    context 'Quand une requête est invalide' do
      let(:payload_invalide) { { nom: '', code_campagne: 'ETE190' } }
      before { post '/api/evaluations', params: payload_invalide }

      it 'retourne une 422' do
        json = JSON.parse(response.body)
        expect(json.keys).to eq %w[nom campagne]
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'GET /evaluations/:id' do
    let(:question) { create :question_qcm, intitule: 'Ma question' }
    let(:questionnaire) { create :questionnaire, questions: [question] }
    let(:campagne) { create :campagne, questionnaire: questionnaire }
    let(:evaluation) { create :evaluation, campagne: campagne }

    it 'retourne les questions de la campagne' do
      get "/api/evaluations/#{evaluation.id}"

      expect(response).to be_ok
      expect(JSON.parse(response.body)['questions'].size).to eql(1)
    end

    it "retourne des questions vide lorsque qu'il n'y a pas de questionnaire" do
      campagne.update(questionnaire: nil)
      get "/api/evaluations/#{evaluation.id}"

      expect(response).to be_ok
      expect(JSON.parse(response.body)['questions'].size).to eql(0)
    end

    it "retourne une 404 lorsqu'elle n'existe pas" do
      get '/api/evaluations/404'

      expect(response).to have_http_status(404)
    end

    it 'retourne les situations de la campagne' do
      situation_controle = create :situation_controle
      situation_inventaire = create :situation_inventaire, libelle: 'Inventaire'

      campagne.situations_configurations.create situation: situation_controle, position: 2
      campagne.situations_configurations.create situation: situation_inventaire, position: 1
      get "/api/evaluations/#{evaluation.id}"

      expect(JSON.parse(response.body)['situations'].size).to eql(2)
      expect(JSON.parse(response.body)['situations'][0]['libelle']).to eql('Inventaire')
    end

    context 'Compétences fortes' do
      let!(:situation_inventaire) { create :situation_inventaire, libelle: 'Inventaire' }
      let!(:demarrage) do
        create(:evenement_demarrage, evaluation: evaluation, situation: situation_inventaire)
      end

      before { campagne.situations << situation_inventaire }

      context 'avec une évaluation avec des compétences identifiées' do
        let!(:saisie) do
          create(:evenement_saisie_inventaire, :ok, situation: situation_inventaire,
                                                    evaluation: evaluation)
        end
        before { get "/api/evaluations/#{evaluation.id}" }

        it do
          attendues = [Competence::RAPIDITE, Competence::VIGILANCE_CONTROLE,
                       Competence::ORGANISATION_METHODE]
          expect(JSON.parse(response.body)['competences_fortes']).to eql(attendues.map(&:to_s))
        end
      end

      context 'avec une évaluation sans compétences identifiées' do
        before { get "/api/evaluations/#{evaluation.id}" }

        it { expect(JSON.parse(response.body)['competences_fortes']).to be_empty }
      end
    end
  end
end
