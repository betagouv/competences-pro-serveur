# frozen_string_literal: true

require 'rails_helper'

describe Structure, type: :model do
  it { should validate_presence_of(:nom) }
  it { should validate_presence_of(:code_postal) }

  describe 'géolocalisation à la validation' do
    let(:structure) { Structure.new code_postal: '75012' }
    before do
      Geocoder::Lookup::Test.add_stub(
        '75012', [
          {
            'coordinates' => [40.7143528, -74.0059731]
          }
        ]
      )
      structure.valid?
    end

    it do
      expect(structure.latitude).to eql(40.7143528)
      expect(structure.longitude).to eql(-74.0059731)
    end

    it { expect(Structure.geocoder_options[:params]).to include(countrycodes: 'fr') }
  end
end
