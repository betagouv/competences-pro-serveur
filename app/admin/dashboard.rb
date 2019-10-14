# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    campagnes = if current_compte.administrateur?
                  Campagne.all
                else
                  Campagne.where(compte: current_compte)
                end

    debut_aujourdhui = Date.current.beginning_of_day
    interval_hier = Date.yesterday.beginning_of_day..debut_aujourdhui
    nombre_evaluations_total = campagnes.sum(:nombre_evaluations)
    nombre_evaluations_hier = campagnes
                              .joins(:evaluations)
                              .where('evaluations.created_at' => interval_hier)
                              .count
    nombre_evaluations_aujourdhui = campagnes
                                    .joins(:evaluations)
                                    .where('evaluations.created_at > ?', debut_aujourdhui)
                                    .count

    render partial: 'dashboard',
           locals: {
             total: nombre_evaluations_total,
             hier: nombre_evaluations_hier,
             aujourdhui: nombre_evaluations_aujourdhui
           }
  end
end
