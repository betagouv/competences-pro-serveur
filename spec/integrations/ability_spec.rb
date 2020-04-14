# frozen_string_literal: true

require 'rails_helper'
require 'cancan/matchers'

describe Ability do
  let(:compte_administrateur) { create :compte, role: 'administrateur' }
  let(:compte_organisation) { create :compte, role: 'organisation' }
  let!(:campagne_administrateur) { create :campagne, compte: compte_administrateur }
  let!(:campagne_administrateur_sans_eval) { create :campagne, compte: compte_administrateur }
  let!(:campagne_organisation) { create :campagne, compte: compte_organisation }

  let!(:evaluation_administrateur) { create :evaluation, campagne: campagne_administrateur }
  let(:situation) { create :situation_inventaire }
  let(:situation_configuration) do
    create :situation_configuration,
           campagne_id: campagne_administrateur,
           situation: situation
  end

  subject(:ability) { Ability.new(compte) }

  context 'Compte administrateur' do
    let(:compte) { compte_administrateur }

    it { is_expected.to be_able_to(:manage, :all) }
    it do
      is_expected.to be_able_to(:read,
                                ActiveAdmin::Page,
                                name: 'Dashboard',
                                namespace_name: 'admin')
    end
    it { is_expected.to be_able_to(%i[read destroy], Evaluation.new) }
    it { is_expected.to_not be_able_to(%i[create update], Evaluation.new) }
    it { is_expected.to_not be_able_to(%i[create update], Evenement.new) }
    it { is_expected.to be_able_to(:read, Evenement.new) }
    it { is_expected.to be_able_to(:manage, Situation.new) }
    it { is_expected.to be_able_to(:manage, Campagne.new) }
    it { is_expected.to be_able_to(:manage, Restitution::Base.new(nil, nil)) }

    it 'avec une campagne qui a des évaluations' do
      is_expected.to_not be_able_to(:destroy, campagne_administrateur)
    end

    it "avec une campagne qui n'a pas d'évaluation" do
      is_expected.to be_able_to(:destroy, campagne_administrateur_sans_eval)
    end

    it 'avec un compte qui est lié à une campagne' do
      is_expected.to_not be_able_to(:destroy, compte_organisation)
    end

    it 'avec une situation utilisé dans des campagne' do
      is_expected.to_not be_able_to(:destroy, situation_configuration.situation)
    end

    it 'avec une situation non utilisé dans des campagne' do
      is_expected.to be_able_to(:destroy, situation)
    end

    describe 'Droits des questionnaires' do
      let(:questionnaire) { create :questionnaire }

      it { is_expected.to be_able_to(:manage, Questionnaire.new) }

      context "quand une campagne l'utilise" do
        let!(:campagne) { create :campagne, questionnaire: questionnaire }

        it { is_expected.to_not be_able_to(:destroy, questionnaire) }
      end

      context "quand une situation l'utilise comme questionnaire principal" do
        let!(:situation) { create :situation_livraison, questionnaire: questionnaire }

        it { is_expected.to_not be_able_to(:destroy, questionnaire) }
      end

      context "quand une situation l'utilise comme questionnaire d'entrainement" do
        let!(:situation) { create :situation_livraison, questionnaire_entrainement: questionnaire }

        it { is_expected.to_not be_able_to(:destroy, questionnaire) }
      end
    end

    describe 'Droits des questions' do
      let(:question) { create(:question) }

      it { is_expected.to be_able_to(:manage, Question.new) }

      context "quand un questionnaire l'utilise" do
        let!(:questionnaire) { create :questionnaire, questions: [question] }

        it { is_expected.to_not be_able_to(:destroy, question) }
      end
    end

    describe 'Droits des choix' do
      let!(:choix) { create :choix, :bon }

      it { is_expected.to be_able_to(:destroy, choix) }

      context 'avec un choix présent dans un événement réponse' do
        let!(:partie) { create :partie }
        let!(:evenement) { create :evenement_reponse, donnees: { reponse: choix.id } }

        it { is_expected.to_not be_able_to(:destroy, choix) }
      end
    end
  end

  context 'Compte organisation' do
    let(:compte)                    { compte_organisation }
    let!(:campagne_organisation)    { create :campagne, compte: compte }
    let(:evaluation_organisation)   { create :evaluation, campagne: campagne_organisation }
    let(:situation)                 { create :situation_inventaire }
    let!(:evenement_administrateur) { create :evenement, partie: partie_administrateur }
    let!(:partie_administrateur) do
      create :partie, session_id: 'test1', evaluation: evaluation_administrateur,
                      situation: situation
    end

    let!(:evenement_organisation) { create :evenement, partie: partie_organisation }
    let!(:partie_organisation) do
      create :partie, session_id: 'test2', evaluation: evaluation_organisation,
                      situation: situation
    end

    it 'avec une campagne qui a des évaluations' do
      is_expected.to_not be_able_to(:destroy, campagne_organisation)
    end

    it { is_expected.to_not be_able_to(:manage, :all) }
    it do
      is_expected.to be_able_to(:read,
                                ActiveAdmin::Page,
                                name: 'Dashboard',
                                namespace_name: 'admin')
    end
    it { is_expected.to_not be_able_to(:manage, Compte.new) }
    it { is_expected.to_not be_able_to(%i[destroy create update], Situation.new) }
    it { is_expected.to_not be_able_to(%i[destroy create update], Question.new) }
    it { is_expected.to_not be_able_to(:manage, Questionnaire.new) }
    it { is_expected.to_not be_able_to(:manage, Campagne.new) }
    it { is_expected.to_not be_able_to(%i[create update], evaluation_organisation) }
    it { is_expected.to_not be_able_to(%i[read destroy], evaluation_administrateur) }
    it { is_expected.to_not be_able_to(:read, Evenement.new) }
    it { is_expected.to_not be_able_to(:read, evenement_administrateur) }
    it { is_expected.to be_able_to(:read, Question.new) }
    it { is_expected.to be_able_to(%i[read destroy], evaluation_organisation) }
    it { is_expected.to be_able_to(:read, evenement_organisation) }
    it { is_expected.to be_able_to(:create, Campagne.new) }
    it { is_expected.to be_able_to(%i[create update read], Campagne.new(compte: compte)) }
    it { is_expected.to be_able_to(:destroy, Campagne.new(compte: compte)) }
    it { is_expected.to be_able_to(:read, Questionnaire.new) }
    it { is_expected.to be_able_to(:read, Situation.new) }
    it { is_expected.to be_able_to(:manage, Restitution::Base.new(campagne_organisation, nil)) }
  end
end
