# frozen_string_literal: true

class PostsReflex < ApplicationReflex

  def filter
    params[element[:name].to_sym] = element.value
  end

end
