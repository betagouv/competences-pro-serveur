# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Base do
  let(:campagne)    { build(:campagne) }
  let(:restitution) { described_class.new(campagne, evenements) }

  context 'lorsque le dernier événement est stop' do
    let(:evenements) do
      [
        build(:evenement_piece_bien_placee),
        build(:evenement_piece_mal_placee),
        build(:evenement_abandon)
      ]
    end

    it { expect(restitution.abandon?).to be(true) }
  end

  it 'renvoie le nombre de réécoute de la consigne' do
    evenements = [
      build(:evenement_demarrage),
      build(:evenement_rejoue_consigne),
      build(:evenement_rejoue_consigne)
    ]
    expect(described_class.new(campagne, evenements).nombre_rejoue_consigne).to eql(2)
  end

  it "envoie l'évaluation associée" do
    evaluation = build(:evaluation)
    evenements = [
      build(:evenement_demarrage, evaluation: evaluation)
    ]
    expect(described_class.new(campagne, evenements).evaluation).to eql(evaluation)
  end

  it 'renvoie par défaut une liste vide pour les compétences évaluées' do
    expect(described_class.new(campagne, []).competences).to eql({})
  end

  describe '#termine?' do
    it "retourne true lorsque l'événement de fin est trouvé" do
      evaluation = build(:evaluation)
      evenements = [
        build(:evenement_demarrage, evaluation: evaluation),
        build(:evenement_fin_situation, evaluation: evaluation)
      ]
      expect(described_class.new(campagne, evenements).termine?).to be true
    end

    it "retourne false lorsque l'événement de fin n'est pas trouvé" do
      evaluation = build(:evaluation)
      evenements = [
        build(:evenement_demarrage, evaluation: evaluation)
      ]
      expect(described_class.new(campagne, evenements).termine?).to be false
    end
  end

  describe '#efficience' do
    let(:restitution) { described_class.new(campagne, []) }

    it "retourne l'efficience sans les compétences persévérance et compréhension consigne" do
      expect(restitution).to receive(:competences).and_return(
        ::Competence::PERSEVERANCE => Competence::NIVEAU_1,
        ::Competence::COMPREHENSION_CONSIGNE => Competence::NIVEAU_1,
        ::Competence::RAPIDITE => Competence::NIVEAU_3,
        ::Competence::COMPARAISON_TRI => Competence::NIVEAU_4,
        ::Competence::ATTENTION_CONCENTRATION => Competence::NIVEAU_4
      )
      expect(restitution.efficience).to eql(91)
    end

    it 'retourne une efficience indéterminé si une compétences indéterminé' do
      expect(restitution).to receive(:competences).and_return(
        ::Competence::RAPIDITE => Competence::NIVEAU_1,
        ::Competence::COMPARAISON_TRI => Competence::NIVEAU_INDETERMINE,
        ::Competence::ATTENTION_CONCENTRATION => Competence::NIVEAU_2
      )
      expect(restitution.efficience).to eql(::Competence::NIVEAU_INDETERMINE)
    end

    it "retourne 0 lorsque rien n'a été mesuré" do
      expect(restitution).to receive(:competences).and_return({})
      expect(restitution.efficience).to eql(0)
    end
  end
end
