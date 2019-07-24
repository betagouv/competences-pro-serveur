# frozen_string_literal: true

module Api
  class EvenementsController < ActionController::API
    def create
      @evenement = Evenement.new(evenement_params)
      if @evenement.save
        render json: @evenement, status: :created
      else
        render json: @evenement.errors.full_messages, status: 422
      end
    end

    private

    def evenement_params
      EvenementParams.from(params)
    end
  end
end
