# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Metriques::Moyenne do
  let(:mock_metrique_a_moyenner) { double }
  let(:metrique_moyenne) do
    described_class.new(mock_metrique_a_moyenner)
  end

  describe '#moyenne' do
    it "rend nil s'il n'y a pas de valeur" do
      expect(mock_metrique_a_moyenner).to receive(:calcule).and_return([])
      expect(metrique_moyenne.calcule([], [])).to eql(nil)
    end

    it "calcul la moyenne d'une valeur" do
      expect(mock_metrique_a_moyenner).to receive(:calcule).and_return([1])
      expect(metrique_moyenne.calcule([], [])).to eql(1.0)
    end

    it 'calcul la moyenne de deux valeurs entières' do
      expect(mock_metrique_a_moyenner).to receive(:calcule).and_return([1, 2])
      expect(metrique_moyenne.calcule([], [])).to eql(1.5)
    end

    it 'arrondi à quatre chiffres après la virgule' do
      expect(mock_metrique_a_moyenner).to receive(:calcule).and_return([1, 1, 2])
      expect(metrique_moyenne.calcule([], [])).to eql(1.3333)
    end
  end
end
