# frozen_string_literal: true

require 'rails_helper'

describe RelanceUtilisateurPourNonActivationJob, type: :job do
  let(:compte) { create :compte_conseiller }

  context "quand le compte n'a pas de campagne" do
    it "envoie un email pour relancer l'utilisateur" do
      expect do
        RelanceUtilisateurPourNonActivationJob.perform_now(compte: compte)
      end.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  context 'quand le compte a une campagne sans passation' do
    let(:campagne) { create :campagne, compte: compte }

    it "envoie un email pour relancer l'utilisateur" do
      expect do
        RelanceUtilisateurPourNonActivationJob.perform_now(compte: compte)
      end.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  context 'quand le compte a une campagne avec des passations' do
    let(:campagne) { create :campagne, compte: compte }

    before { create :evaluation, campagne: campagne }

    it 'ne fais rien' do
      expect do
        RelanceUtilisateurPourNonActivationJob.perform_now(compte: compte)
      end.to change { ActionMailer::Base.deliveries.count }.by(0)
    end
  end
end
