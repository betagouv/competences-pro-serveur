# frozen_string_literal: true

require 'rails_helper'

describe Restitution::StandardisateurGlissant do
  context 'peut figer certaines métriques' do
    let(:standards_figes) do
      {
        temps_moyen_recherche_zones_dangers: { average: 12, stddev_pop: 3 }
      }
    end
    let(:subject) do
      described_class.new ['temps_moyen_recherche_zones_dangers'], proc {}, standards_figes
    end

    it { expect(subject.moyennes_metriques).to eq('temps_moyen_recherche_zones_dangers' => 12) }
    it { expect(subject.ecarts_types_metriques).to eq('temps_moyen_recherche_zones_dangers' => 3) }
  end
end
