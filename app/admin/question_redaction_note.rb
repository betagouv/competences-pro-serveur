# frozen_string_literal: true

ActiveAdmin.register QuestionRedactionNote do
  menu parent: 'Parcours'

  permit_params :libelle, :intitule, :illustration, :entete_reponse, :expediteur,
                :message, :objet_reponse

  filter :libelle

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :libelle
      f.input :intitule
      f.input :illustration, as: :file
      f.input :entete_reponse
      f.input :expediteur
      f.input :message
      f.input :objet_reponse
    end
    f.actions
  end

  index do
    column :libelle
    column :intitule
    column :created_at
    actions
  end

  show do
    render partial: 'show'
  end
end
