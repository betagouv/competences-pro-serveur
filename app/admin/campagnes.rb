# frozen_string_literal: true

ActiveAdmin.register Campagne do
  config.batch_actions = false
  permit_params :libelle, :code, :questionnaire_id, :compte, :compte_id,
                situations_configurations_attributes: %i[id situation_id _destroy]

  filter :compte, if: proc { can? :manage, Compte }
  filter :situations
  filter :questionnaire

  includes :compte

  index do
    selectable_column
    column :libelle
    column :code
    column :nombre_evaluations
    column :compte if can?(:manage, Compte)
    actions
  end

  show do
    render partial: 'show'
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :compte if can?(:manage, Compte)
      f.input :libelle
      f.input :code
      f.input :questionnaire
      f.has_many :situations_configurations, allow_destroy: true do |c|
        c.input :id, as: :hidden
        c.input :situation
      end
    end
    f.actions
  end

  sidebar 'Voir...', only: :show do
    ul do
      li link_to 'Les stats', admin_campagne_stats_path(q: { campagne_id_eq: resource.id })
      li link_to "#{resource.nombre_evaluations} évaluations",
                 admin_campagne_evaluations_path(resource)
    end
  end

  controller do
    def create
      params[:campagne][:compte_id] ||= current_compte.id
      create!
    end
  end
end
