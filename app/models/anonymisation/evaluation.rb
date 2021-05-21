# frozen_string_literal: true

module Anonymisation
  class Evaluation < Anonymisation::Base
    def anonymise
      super do |evaluation|
        evaluation.nom = FFaker::Name.name
        evaluation.email = nil
        evaluation.telephone = nil
      end
    end
  end
end
