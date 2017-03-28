class RecipesController < ApplicationController
  before_filter :authenticate_user!, except: [ :index, :show ]

  def index
    @recipes = Recipe.all
  end

  def show
    @recipe = Recipe.find(params[:id])
  end

  def new
    @recipe = Recipe.new
  end

  def edit
    @recipe = Recipe.find(params[:id])
  end

  def create
    @recipe = Recipe.new(recipe_params)
    @recipe.user_id = current_user.id
    if @recipe.save
      redirect_to @recipe
    else
      render 'new'
    end
  end

  def update
    @recipe = Recipe.find(params[:id])
    @recipe.user = current_user.id
    if @recipe.update(recipe_params)
      redirect_to @recipe
    else
      render 'edit'
    end
  end

  def destroy
    @recipe = Recipe.find(params[:id])
    if @recipe.user_id = current_user.id
      @recipe.destroy
    end

    redirect_to recipes_path
  end
end

private
  def recipe_params
    params.require(:recipe).permit(:name, :description, :source, :category, :prep_time, :servings, :cals_serving, :attachments, :notes,
      :ingredient1,
      :ingredient2,
      :ingredient3,
      :ingredient4,
      :ingredient5,
      :ingredient6,
      :ingredient7,
      :ingredient8,
      :ingredient9,
      :ingredient10,
      :ingredient11,
      :ingredient12,
      :ingredient13,
      :ingredient14,
      :ingredient15,
      :ingredient16,
      :ingredient17,
      :ingredient18,
      :ingredient19,
      :ingredient20,
      :ingredient21,
      :ingredient22,
      :quantity1,
      :quantity2,
      :quantity3,
      :quantity4,
      :quantity5,
      :quantity6,
      :quantity7,
      :quantity8,
      :quantity9,
      :quantity10,
      :quantity11,
      :quantity12,
      :quantity13,
      :quantity14,
      :quantity15,
      :quantity16,
      :quantity17,
      :quantity18,
      :quantity19,
      :quantity20,
      :quantity21,
      :quantity22,
      :instruction1,
      :instruction2,
      :instruction3,
      :instruction4,
      :instruction5,
      :instruction6,
      :instruction7,
      :instruction8,
      :instruction9,
      :instruction10,
      :instruction11,
      :instruction12,
      :instruction13,
      :instruction14,
      :instruction15,
      :instruction16,
      :instruction17,
      :instruction18,
      :instruction19,
      :instruction20)
  end
