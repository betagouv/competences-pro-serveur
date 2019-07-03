# frozen_string_literal: true

module Restitution
  class Controle
    class ComparaisonTri < Restitution::Competence::Base
      def initialize(restitution)
        super(restitution)
        @restitution_hors_4_premiers = restitution.enleve_premiers_evenements_pieces(4)
      end

      def niveau
        return ::Competence::NIVEAU_INDETERMINE if @restitution.evenements.count < 4

        nombre_erreur = @restitution_hors_4_premiers.nombre_mal_placees
        case nombre_erreur
        when 0 then ::Competence::NIVEAU_4
        when 1 then ::Competence::NIVEAU_3
        when 2 then ::Competence::NIVEAU_2
        else ::Competence::NIVEAU_1
        end
      end
    end
  end
end
