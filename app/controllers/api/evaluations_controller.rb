# frozen_string_literal: true

module Api
  class EvaluationsController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound do
      render status: :not_found
    end

    def create
      evaluation = Evaluation.new(EvaluationParams.from(params))
      if evaluation.save
        render json: evaluation, status: :created
      else
        render json: evaluation.errors, status: 422
      end
    end

    def show
      evaluation = Evaluation.find(params[:id])
      situations = evaluation.campagne.situations
      questions = evaluation.campagne.questionnaire&.questions || []
      competences = FabriqueRestitution.restitution_globale(evaluation).nom_competences
      render json: { questions: questions, situations: situations, competences_fortes: competences }
    end
  end
end
