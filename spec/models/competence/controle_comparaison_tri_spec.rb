# frozen_string_literal: true

require 'rails_helper'

describe Competence::ControleComparaisonTri do
  let(:evaluation) { double }
  let(:evaluation_hors_4_premiers) { double }

  before(:each) do
    allow(evaluation).to receive(:evenements).and_return([1, 2, 3, 4])
    allow(evaluation).to receive(:shift).with(4).and_return(evaluation_hors_4_premiers)
  end

  context "lorsqu'il n'y a pas d'erreurs ou de ratées" do
    it 'a le niveau 4' do
      expect(evaluation_hors_4_premiers).to receive(:nombre_mal_placees).and_return(0)
      expect(
        described_class.new(evaluation).niveau
      ).to eql(Competence::NIVEAU_4)
    end
  end

  context "lorsqu'il y a une pièce mal placée hors 4 premières" do
    it 'a le niveau 3' do
      expect(evaluation_hors_4_premiers).to receive(:nombre_mal_placees).and_return(1)
      expect(
        described_class.new(evaluation).niveau
      ).to eql(Competence::NIVEAU_3)
    end
  end

  context "lorsqu'il y a deux pièces mal placées hors 4 premières" do
    it 'a le niveau 2' do
      expect(evaluation_hors_4_premiers).to receive(:nombre_mal_placees).and_return(2)
      expect(
        described_class.new(evaluation).niveau
      ).to eql(Competence::NIVEAU_2)
    end
  end

  context "lorsqu'il y a trois pièces mal placéee hors 4 premières" do
    it 'a le niveau 1' do
      expect(evaluation_hors_4_premiers).to receive(:nombre_mal_placees).and_return(3)
      expect(
        described_class.new(evaluation).niveau
      ).to eql(Competence::NIVEAU_1)
    end
  end

  context "lorsqu'il n'y a que 3 événements" do
    let(:evenements) do
      [
        build(:evenement_piece_bien_placee),
        build(:evenement_piece_mal_placee)
      ]
    end

    it 'a le niveau indéfini' do
      expect(evaluation).to receive(:evenements).and_return([1, 2, 3])
      expect(
        described_class.new(evaluation).niveau
      ).to eql(Competence::NIVEAU_INDETERMINE)
    end
  end
end
