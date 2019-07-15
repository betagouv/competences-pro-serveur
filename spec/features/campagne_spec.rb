# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Campagne', type: :feature do
  before { se_connecter_comme_administrateur }
  let!(:campagne) { create :campagne, libelle: 'Amiens 18 juin', code: 'A5RC8' }
  let!(:evaluation) { create :evaluation, campagne: campagne }

  describe 'index' do
    before { visit admin_campagnes_path }
    it do
      expect(page).to have_content 'Amiens 18 juin'
      expect(page).to have_content 'A5RC8'
    end
  end

  describe 'création' do
    before do
      visit new_admin_campagne_path
      fill_in :campagne_libelle, with: 'Belfort, pack demandeur'
    end

    it { expect { click_on 'Créer' }.to(change { Campagne.count }) }
  end

  describe 'show' do
    before { visit admin_campagne_path campagne  }
    it { expect(page).to have_content 'Roger' }
  end
end
