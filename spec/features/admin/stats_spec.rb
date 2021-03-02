# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Stats', type: :feature do
  let(:compte_organisation) { create :compte_organisation, email: 'orga@eva.fr' }
  let!(:campagne) do
    create :campagne, libelle: 'Rouen 30 mars', code: 'A5ROUEN',
                      compte: compte_organisation, questionnaire: questionnaire
  end
  let(:choix) { create :choix, type_choix: :bon, intitule: 'Test' }
  let(:question) { create :question_qcm, libelle: 'Test', intitule: 'Test', choix: [choix] }
  let(:questionnaire) { create :questionnaire, questions: [question] }
  let!(:evaluation) { create :evaluation, nom: 'Roger', campagne: campagne }
  let(:restitution_inventaire) do
    double(
      situation: Situation.new(nom_technique: 'inventaire'),
      efficience: 2,
      temps_total: 3,
      nombre_ouverture_contenant: 4,
      nombre_essais_validation: 5
    )
  end
  let(:restitution_controle) do
    double(
      situation: Situation.new(nom_technique: 'controle'),
      efficience: 6,
      nombre_bien_placees: 7,
      nombre_mal_placees: 8,
      nombre_non_triees: 9
    )
  end
  let(:restitution_tri) do
    double(
      situation: Situation.new(nom_technique: 'tri'),
      efficience: 10,
      temps_total: 11,
      nombre_bien_placees: 12,
      nombre_mal_placees: 13
    )
  end
  let(:restitution_bureau) do
    double(
      situation: Situation.new(nom_technique: 'questions'),
      temps_total: 15,
      choix_repondu: choix
    )
  end

  let(:restitutions_securite) do
    double(
      situation: Situation.new(nom_technique: 'securite'),
      temps_entrainement: 'temps_entrainement',
      temps_total: 16,
      nombre_dangers_bien_identifies: 17,
      nombre_dangers_mal_identifies: 18,
      nombre_dangers_bien_identifies_avant_aide1: 19,
      nombre_bien_qualifies: 20,
      nombre_retours_deja_qualifies: 21,
      delai_moyen_ouvertures_zones_dangers: 22,
      attention_visuo_spatiale: 'apte',
      nombre_reouverture_zones_sans_danger: 23,
      temps_bonnes_qualifications_dangers: { 'bouche-egout' => 'tbqd1', 'camion' => 'tbqd2',
                                             'casque' => 'tbqd3', 'escabeau' => 'tbqd4',
                                             'signalisation' => 'tbqd5' },
      temps_recherche_zones_dangers: { 'bouche-egout' => 'trzd1', 'camion' => 'trzd2',
                                       'casque' => 'trzd3', 'escabeau' => 'trzd4',
                                       'signalisation' => 'trzd5' },
      temps_total_ouverture_zones_dangers: { 'bouche-egout' => 'ttozd1', 'camion' => 'ttozd2',
                                             'casque' => 'ttozd3', 'escabeau' => 'ttozd4',
                                             'signalisation' => 'ttozd5' }
    )
  end

  describe 'index' do
    before do
      restitution_globale = double(efficience: 1,
                                   restitutions: [
                                     restitution_inventaire,
                                     restitution_controle,
                                     restitution_tri,
                                     restitutions_securite,
                                     restitution_bureau
                                   ])
      expect(restitution_globale).to receive(:efficience).and_return(1)
      expect(FabriqueRestitution).to receive(:restitution_globale).and_return(restitution_globale)
      connecte compte_organisation
      visit admin_campagne_stats_path(campagne)
    end

    it do
      expect(page).to have_content 'Roger'
      content = all(:css, 'tbody tr td').map(&:text)[2..]
      expect(content).to eql(%w[1 2 3 4 5 6 7 8 9 10 11 12 13 15 temps_entrainement
                                16 17 18 19 20 21 22 apte 23
                                tbqd1 tbqd2 tbqd3 tbqd4 tbqd5
                                trzd1 trzd2 trzd3 trzd4 trzd5
                                ttozd1 ttozd2 ttozd3 ttozd4 ttozd5
                                bon])
    end
  end
end
