# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Campagne', type: :feature do
  let!(:compte_connecte) { se_connecter_comme_organisation }
  let(:premier_compte) { Compte.order(created_at: :desc).last }
  let!(:ma_campagne) do
    create :campagne, libelle: 'Amiens 18 juin', code: 'A5RC8', compte: premier_compte
  end
  let(:compte_organisation) { create :compte_organisation, email: 'orga@eva.fr' }
  let!(:campagne) do
    create :campagne, libelle: 'Rouen 30 mars', code: 'A5ROUEN', compte: compte_organisation
  end
  let!(:evaluation) { create :evaluation, campagne: campagne }
  let(:derniere_campagne) { Campagne.order(created_at: :desc).first }

  describe 'index' do
    context 'en organisation' do
      before { visit admin_campagnes_path }

      it do
        expect(page).to have_content 'Amiens 18 juin'
        expect(page).to have_content 'A5RC8'
        expect(page).to_not have_content 'Rouen 30 mars'
      end

      it 'ne permet pas de filtrer par compte' do
        within '.panel_contents' do
          expect(page).to_not have_content 'Compte'
        end
      end
    end

    context 'en administrateur' do
      before do
        compte_connecte.update(role: 'administrateur')
        visit admin_campagnes_path
      end

      it 'permet de filtrer par compte' do
        within '.panel_contents' do
          expect(page).to have_content 'Compte'
        end
      end
    end
  end

  describe 'création' do
    let!(:questionnaire) { create :questionnaire, libelle: 'Mon QCM' }

    context 'en organisation' do
      before do
        visit new_admin_campagne_path
        fill_in :campagne_libelle, with: 'Belfort, pack demandeur'
      end

      context 'génère un code si on en saisit pas' do
        before do
          fill_in :campagne_code, with: ''
          select 'Mon QCM'
        end

        it do
          expect { click_on 'Créer' }.to(change { Campagne.count })
          expect(derniere_campagne.code).to be_present
          expect(derniere_campagne.compte).to eq compte_connecte
          expect(page).to have_content 'Mon QCM'
        end

        context 'conserve le code saisi si précisé' do
          before { fill_in :campagne_code, with: 'EUROCKS' }
          it do
            expect { click_on 'Créer' }.to(change { Campagne.count })
            expect(derniere_campagne.code).to eq 'EUROCKS'
          end
        end
      end
    end

    context 'en administrateur' do
      before do
        premier_compte.update(role: 'administrateur')
        visit new_admin_campagne_path
        fill_in :campagne_libelle, with: 'Belfort, pack demandeur'
        fill_in :campagne_code, with: ''
        select 'Mon QCM'
        select 'orga@eva.fr'
      end

      it do
        expect { click_on 'Créer' }.to(change { Campagne.count })
        expect(derniere_campagne.compte).to eq compte_organisation
      end
    end
  end

  describe 'show' do
    let(:situation) { create :situation_inventaire }
    before do
      premier_compte.update(role: 'administrateur')
      campagne.situations_configurations.create! situation: situation
      visit admin_campagne_path campagne
    end
    it { expect(page).to have_content 'Roger' }
  end
end
