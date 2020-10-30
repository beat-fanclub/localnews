# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Post
    can :read, Comment
    can :read, Tag
    return unless user.present?
    can :manage, Post, user_id: user.id
    can :create, Comment, user_id: user.id, edited: false
    can [:update, :destroy], Comment, user_id: user.id
  end
end
