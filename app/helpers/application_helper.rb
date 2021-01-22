# frozen_string_literal: true

module ApplicationHelper
  def formate_efficience(nombre)
    return I18n.t("admin.restitutions.evaluation.#{nombre}") if nombre.is_a?(Symbol)

    number_to_percentage(nombre, precision: 0)
  end

  def formate_duree(duree)
    return if duree.blank?

    duree = duree.to_i
    heure_minutes_secondes = [duree / 3600, duree / 60 % 60, duree % 60]
    heure_minutes_secondes.shift if heure_minutes_secondes[0].zero?
    heure_minutes_secondes.map { |t| t.to_s.rjust(2, '0') }.join(':')
  end

  def rapport_colonne_class
    'col-4 px-5 mb-4'
  end

  def md(contenu)
    @markdown ||= Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(hard_wrap: true)
    )
    @markdown.render(contenu).html_safe
  end

  def svg_tag_base64(path, options = {})
    raw = Rails.application.assets_manifest.find_sources(path).first
    encodage = Base64.strict_encode64 raw
    image_src64 = "data:image/svg+xml;base64,#{encodage}"
    image_tag image_src64, options
  end
end
