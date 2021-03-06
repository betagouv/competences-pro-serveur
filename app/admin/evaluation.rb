# frozen_string_literal: true

ActiveAdmin.register Evaluation do
  permit_params :campagne_id, :nom, :email, :telephone, :terminee_le
  menu priority: 4

  includes :campagne

  config.sort_order = 'created_at_desc'

  filter :nom
  filter :campagne_id,
         as: :search_select_filter,
         url: proc { admin_campagnes_path },
         fields: %i[libelle code],
         display_name: 'display_name',
         minimum_input_length: 2,
         order_by: 'libelle_asc'
  filter :created_at

  action_item :pdf_restitution, only: :show do
    link_to('Export PDF', {
              parties_selectionnees: params[:parties_selectionnees],
              format: :pdf
            },
            target: '_blank')
  end

  index download_links: lambda {
                          params[:action] == 'show' ? [:pdf] : %i[csv xls json]
                        }, row_class: lambda { |elem|
                                        'anonyme' if elem.anonyme?
                                      } do
    column(:nom) { |e| nom_pour_evaluation(e) }
    column :campagne
    column :created_at
    actions
  end

  show do
    params[:parties_selectionnees] =
      FabriqueRestitution.initialise_selection(resource,
                                               params[:parties_selectionnees])
    render partial: 'show'
  end

  sidebar :menu, class: 'menu-sidebar', only: :show

  form partial: 'form'

  controller do
    helper_method :restitution_globale, :parties, :auto_positionnement, :statistiques,
                  :mes_avec_redaction_de_notes

    def show
      show! do |format|
        format.html
        format.pdf { render pdf: resource.nom }
      end
    end

    def destroy
      destroy!(location: admin_campagne_path(resource.campagne))
    end

    before_action only: :show do
      flash.now[:evaluation_anonyme] = t('.evaluation_anonyme') if resource.anonyme?
    end

    private

    def statistiques
      @statistiques ||= StatistiquesEvaluation.new(resource)
    end

    def restitution_globale
      @restitution_globale ||=
        FabriqueRestitution.restitution_globale(resource, params[:parties_selectionnees])
    end

    def mes_avec_redaction_de_notes
      @mes_avec_redaction_de_notes ||= restitution_globale.restitutions.select do |restitution|
        %w[questions livraison].include?(restitution.situation.nom_technique) &&
          !restitution.questions_redaction.empty?
      end
    end

    def auto_positionnement
      restitution_globale.restitutions.select do |restitution|
        restitution.situation.nom_technique == Restitution::Bienvenue::NOM_TECHNIQUE
      end.last
    end

    def parties
      Partie.where(evaluation_id: resource).includes(:situation).order(:created_at)
    end
  end
end
