# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Livraison do
  let(:evaluation) { create :evaluation, nom: 'Test' }
  let(:bon_choix_q1) { create :choix, :bon }
  let(:question1) do
    create :question_qcm, metacompetence: :numeratie, choix: [bon_choix_q1]
  end
  let(:question2) { create :question_qcm }
  let(:questionnaire) { create :questionnaire, questions: [question1, question2] }
  let!(:partie) { create :partie, situation: situation, evaluation: evaluation }
  let(:situation) do
    create :situation,
           libelle: 'Livraison',
           nom_technique: 'livraison',
           questionnaire: questionnaire
  end
  let(:campagne) { build :campagne }
  let(:restitution) { described_class.new(campagne, evenements) }
  let(:evenements) do
    [build(:evenement_demarrage)] + evenements_reponses
  end
  let(:evenements_reponses) { [] }

  describe '#termine?' do
    context "lorsque aucune questions n'a encore été répondu" do
      it { expect(restitution).to_not be_termine }
    end

    context 'lorsque une des questions a été répondu' do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_reponse, donnees: { question: question1.id, reponse: 1 })
        ]
      end
      it { expect(restitution).to_not be_termine }
    end

    context 'lorsque les 2 questions ont été répondu' do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_reponse, donnees: { question: question1.id, reponse: 1 }),
          build(:evenement_reponse, donnees: { question: question2.id, reponse: 2 })
        ]
      end
      it { expect(restitution).to be_termine }
    end

    context "avec l'événement de fin de situation" do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_fin_situation)
        ]
      end

      it { expect(restitution).to be_termine }
    end
  end

  describe '#questions_et_reponses' do
    context "retourne aucune question et réponse si aucune n'a été répondu" do
      it { expect(restitution.questions_et_reponses).to eq([]) }
    end

    context 'retourne les questions et les réponses du questionnaire' do
      let(:evenements_reponses) do
        [
          build(:evenement_reponse,
                donnees: { question: question1.id, reponse: bon_choix_q1.id })
        ]
      end
      it do
        expect(restitution.questions_et_reponses.size).to eq(1)
        expect(restitution.questions_et_reponses.first[:question]).to eql(question1)
        expect(restitution.questions_et_reponses.first[:reponse]).to eql(bon_choix_q1)
      end
    end

    context 'ignore les réponses aux questions qui ne sont pas une Question QCM' do
      let(:question_redaction_note) { create :question_redaction_note }
      let(:questionnaire) { create :questionnaire, questions: [question_redaction_note] }

      let(:evenements_reponses) do
        [
          build(:evenement_reponse,
                donnees: { question: question_redaction_note.id, reponse: 'coucou' })
        ]
      end
      it { expect(restitution.questions_et_reponses).to eq([]) }
    end
  end

  describe '#reponses' do
    context 'retourne uniquement les réponses' do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_reponse)
        ]
      end
      it { expect(restitution.reponses.size).to eql(1) }
    end
  end

  describe '#efficience' do
    it 'retourne nil' do
      expect(restitution.efficience).to be_nil
    end
  end

  describe '#persiste' do
    context "persiste l'ensemble des données de livraison" do
      it do
        expect(restitution).to receive(:nombre_bonnes_reponses_ccf).and_return 2
        expect(restitution).to receive(:nombre_bonnes_reponses_numeratie).and_return 1
        expect(restitution).to receive(:nombre_bonnes_reponses_syntaxe_orthographe).and_return 3
        expect(restitution).to receive(:temps_moyen_bonnes_reponses_numeratie).and_return 0.789
        expect(restitution).to receive(:temps_moyen_bonnes_reponses_ccf).and_return 2.122
        expect(restitution).to receive(:temps_moyen_bonnes_reponses_syntaxe_orthographe)
          .and_return 10.965

        restitution.persiste
        partie.reload
        expect(partie.metriques['nombre_bonnes_reponses_ccf']).to eq 2
        expect(partie.metriques['nombre_bonnes_reponses_numeratie']).to eq 1
        expect(partie.metriques['nombre_bonnes_reponses_syntaxe_orthographe']).to eq 3
        expect(partie.metriques['temps_moyen_bonnes_reponses_numeratie']).to eq 0.789
        expect(partie.metriques['temps_moyen_bonnes_reponses_ccf']).to eq 2.122
        expect(partie.metriques['temps_moyen_bonnes_reponses_syntaxe_orthographe']).to eq 10.965
      end
    end
  end
end
