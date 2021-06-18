# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/compte_mailer
class CompteMailerPreview < ActionMailer::Preview
  def nouveau_compte
    structure = Structure.new nom: 'Ma Super Structure'
    compte = Compte.new prenom: 'Paule', email: 'debut@test.com', structure: structure
    CompteMailer.with(compte: compte).nouveau_compte
  end

  def relance
    structure = Structure.new type_structure: 'mission_locale'
    compte = Compte.new prenom: 'Lucas', structure: structure, email: 'lucas.dupont@example.com'

    CompteMailer.with(compte: compte).relance
  end
end
