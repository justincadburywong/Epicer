class RecipesController < ApplicationController
  def new
  end

  def create
    @recipe = Recipe.new(params[:recipe])
    @recipe.save
    redirect_to @recipe
  end

  def update
  end

  def delete
  end
end
