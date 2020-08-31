# frozen_string_literal: true

module Restitution
  module Illettrisme
    class InterpreteurNiveau2 < InterpreteurScores
      PALIERS_LITTERATIE = {
        score_ccf: %i[niveau1 niveau2 niveau3],
        score_syntaxe_orthographe: %i[niveau1 niveau2 niveau3],
        score_memorisation: %i[niveau1 niveau2 niveau3]
      }.freeze

      PALIERS_NUMERATIE = {
        score_numeratie: %i[niveau1 niveau2 niveau3]
      }.freeze
    end
  end
end
