# frozen_string_literal: true

class StructuresController < ApplicationController
  layout 'active_admin_logged_out'
  helper ::ActiveAdmin::ViewHelpers

  def index
    @structures = Structure.near("#{params[:code_postal]}, FRANCE")
  end
end
