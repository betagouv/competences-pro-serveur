# frozen_string_literal: true

module Restitution
  class Bienvenue < Base
    def questions_et_reponses
      qr = QuestionsReponses.new(evenements, situation.questionnaire)
      qr.questions_et_reponses
    end
  end
end
