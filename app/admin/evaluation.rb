# frozen_string_literal: true

ActiveAdmin.register Evaluation do
  filter :campagne, collection: proc { evaluations_visibles }
  filter :created_at
  config.sort_order = 'created_at_desc'
  includes :campagne

  index do
    column :nom
    column :campagne
    column :created_at
    actions
  end

  action_item :pdf, only: :show, if: proc { restitution_globale.present? } do
    link_to('Export PDF', {
              restitutions_selectionnees: params[:restitutions_selectionnees],
              format: :pdf
            },
            target: '_blank')
  end

  show do
    default_main_content
    params[:restitutions_selectionnees] =
      FabriqueRestitution.initialise_selection(params[:id],
                                               params[:restitutions_selectionnees])
    render partial: 'show'
  end

  controller do
    helper_method :evaluations_visibles, :restitutions, :restitution_globale

    def show
      show! do |format|
        format.html
        format.pdf { render pdf: resource.nom }
      end
    end

    private

    def restitutions
      Evenement.where(nom: 'demarrage', evaluation_id: params[:id])
    end

    def evaluations_visibles
      current_compte.administrateur? ? Campagne.all : Campagne.where(compte: current_compte)
    end

    def restitution_globale
      FabriqueRestitution.restitution_globale(resource, params[:restitutions_selectionnees])
    end
  end
end
