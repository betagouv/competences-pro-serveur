# frozen_string_literal: true

require 'rails_helper'

describe Evaluation::Inventaire::Rapidite do
  let(:evaluation) { double }

  def pour(reussite: nil, minutes: nil)
    expect(evaluation).to receive(:reussite?).and_return(reussite)
    secondes = minutes.minutes.to_i if minutes
    allow(evaluation).to receive(:temps_total).and_return(secondes)
    described_class.new(evaluation)
  end

  it { expect(pour(reussite: false)).to evalue_a(Competence::NIVEAU_INDETERMINE) }

  it { expect(pour(reussite: true, minutes: 0)).to evalue_a(Competence::NIVEAU_4) }
  it { expect(pour(reussite: true, minutes: 10)).to evalue_a(Competence::NIVEAU_4) }
  it { expect(pour(reussite: true, minutes: 11)).to evalue_a(Competence::NIVEAU_3) }
  it { expect(pour(reussite: true, minutes: 15)).to evalue_a(Competence::NIVEAU_3) }
  it { expect(pour(reussite: true, minutes: 16)).to evalue_a(Competence::NIVEAU_2) }
  it { expect(pour(reussite: true, minutes: 30)).to evalue_a(Competence::NIVEAU_2) }
  it { expect(pour(reussite: true, minutes: 31)).to evalue_a(Competence::NIVEAU_1) }
end
