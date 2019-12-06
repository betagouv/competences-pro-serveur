# frozen_string_literal: true

require 'rails_helper'

describe EvenementParams do
  describe '#from' do
    let!(:situation) { create :situation_inventaire }

    it 'filtre les parametres' do
      params = ActionController::Parameters.new(
        nom: 'mon nom',
        date: 'ma date',
        donnees: {},
        session_id: 'ma session id',
        autre_param: 'autre paramètre'
      )

      evenement_params = described_class.from(params)
      expect(evenement_params.keys.sort).to eql(
        %w[date donnees nom session_id]
      )
    end
  end
end
