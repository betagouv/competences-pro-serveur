# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(compte)
    droits_generiques
    droit_campagne compte
    droit_evaluation compte
    droit_evenement compte
    droit_situation compte
    droit_question compte
    cannot :manage, Compte unless compte.administrateur?
  end

  private

  def droit_campagne(compte)
    cannot :manage, Campagne unless compte.administrateur?
    can :create, Campagne
    can %i[update read destroy], Campagne, compte_id: compte.id
  end

  def droit_evaluation(compte)
    cannot :manage, Evaluation unless compte.administrateur?
    can :manage, Evaluation, campagne: { compte_id: compte.id }
  end

  def droit_evenement(compte)
    cannot :read, Evenement unless compte.administrateur?
    can :read, Evenement, evaluation: { campagne: { compte_id: compte.id } }
  end

  def droit_situation(compte)
    cannot :manage, Situation unless compte.administrateur?
    can :read, Situation
  end

  def droit_question(compte)
    cannot :manage, Question unless compte.administrateur?
    can :read, Question
  end

  def droits_generiques
    can :manage, :all
    cannot %i[destroy create], Evaluation
    cannot %i[update create], Evenement
  end
end
