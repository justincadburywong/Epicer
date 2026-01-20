class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[show edit update destroy]

  def index
    @recipes = Recipe.order(created_at: :desc)
  end

  def show
  end

  def new
    @recipe = Recipe.new
    @recipe.ingredients.build
  end

  def create
    @recipe = Recipe.new(recipe_params)

    if @recipe.save
      redirect_to @recipe, notice: "Recipe was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @recipe.update(recipe_params)
      redirect_to @recipe, notice: "Recipe was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recipe.destroy
    redirect_to recipes_url, notice: "Recipe was successfully deleted."
  end

  private

  def set_recipe
    @recipe = Recipe.friendly.find(params[:id])
  end

  def recipe_params
    params.require(:recipe).permit(
      :title, :description, :instructions, :source_url,
      :prep_time, :cook_time, :servings, :rating, :notes,
      images: [], documents: [],
      ingredients_attributes: %i[id name quantity unit position _destroy]
    )
  end
end
