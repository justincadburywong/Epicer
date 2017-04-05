require 'rails_helper'

RSpec.describe Recipe, type: :model do
  describe "Model" do
    before do
      @user = FactoryGirl.create(:user)
      @recipe = FactoryGirl.build(:recipe)
      @recipe.user_id = @user.id
    end

    # context "Attributes" do
    #   it 'are readable' do
    #     expect(@recipe.name).to eq ''
    #     expect(@recipe.description).to eq ''
    #     expect(@recipe.category).to eq ''
    #     expect(@recipe.ingredient1).to eq ''
    #     expect(@recipe.quantity1).to eq ''
    #     expect(@recipe.instruction1).to eq ''
    #   end
    # end

    context "Validations" do

      it "should validate name" do
        should validate_presence_of(:name)
        should validate_length_of(:name)
        .is_at_most 32
      end

      it "should validate description" do
        should validate_presence_of(:description)
        should validate_length_of(:description)
        .is_at_least 3
      end

      it "should validate category" do
        should validate_presence_of(:category)
        should validate_length_of(:category)
      end

      it "should validate ingredient1" do
        should validate_presence_of(:ingredient1)
        should validate_length_of(:ingredient1)
      end

      it "should validate quantity1" do
        should validate_presence_of(:quantity1)
        should validate_length_of(:quantity1)
      end

      it "should validate instruction1" do
        should validate_presence_of(:instruction1)
        should validate_length_of(:instruction1)
      end

    end

    context "#save" do
      it "should save correctly when valid" do
        expect {
          @recipe.save
        }.to change(Recipe, :count).by(1)
      end

      it "should not save when name is empty" do
        @recipe.name = ""
        expect {
          @recipe.save
        }.not_to change(Recipe, :count)
      end

      it "should not save when name is nil" do
        @recipe.name = nil
        expect {
          @recipe.save
        }.not_to change(Recipe, :count)
      end
    end

    context "#update" do
      it "should correctly change the name" do
        @recipe.update(name: "BA's Best Chicken")
        expect(@recipe.name).to eq("BA's Best Chicken")
      end
      it "should correctly change the description" do
        @recipe.update(description: "Hot hot hot")
        expect(@recipe.description).to eq("Hot hot hot")
      end
      it "should correctly change the source" do
        @recipe.update(source: "http://www.bonappetit.com/story/easiest-roast-chicken-recipe")
        expect(@recipe.source).to eq("http://www.bonappetit.com/story/easiest-roast-chicken-recipe")
      end
      it "should correctly change the category" do
        @recipe.update(category: "Chicken, Bon Appetit")
        expect(@recipe.category).to eq("Chicken, Bon Appetit")
      end
      it "should correctly change the prep_time" do
        @recipe.update(prep_time: "1 hour")
        expect(@recipe.prep_time).to eq("1 hour")
      end
      it "should correctly change the servings" do
        @recipe.update(servings: "6")
        expect(@recipe.servings).to eq("6")
      end
      it "should correctly change the cals_serving" do
        @recipe.update(cals_serving: "630")
        expect(@recipe.cals_serving).to eq("630")
      end
      it "should correctly change the notes" do
        @recipe.update(notes: "This recipe eliminates one of the most common complaints about whole roast chickens - that it's hard to know when they're cooked all the way through.")
        expect(@recipe.notes).to eq("This recipe eliminates one of the most common complaints about whole roast chickens - that it's hard to know when they're cooked all the way through.")
      end
      it "should correctly change the ingredient1" do
        @recipe.update(ingredient1: "Chicken")
        expect(@recipe.ingredient1).to eq("Chicken")
      end
      it "should correctly change the ingredient2" do
        @recipe.update(ingredient2: "Kosher Salt")
        expect(@recipe.ingredient2).to eq("Kosher Salt")
      end
      it "should correctly change the ingredient3" do
        @recipe.update(ingredient3: "Lemon, halved crosswise, seeds removed")
        expect(@recipe.ingredient3).to eq("Lemon, halved crosswise, seeds removed")
      end
      it "should correctly change the ingredient4" do
        @recipe.update(ingredient4: "Head of garlic, halved crosswise")
        expect(@recipe.ingredient4).to eq("Head of garlic, halved crosswise")
      end
      it "should correctly change the ingredient5" do
        @recipe.update(ingredient5: "Unsalted butter, melted")
        expect(@recipe.ingredient5).to eq("Unsalted butter, melted")
      end
      it "should correctly change the ingredient6" do
        @recipe.update(ingredient6: "3.00")
        expect(@recipe.ingredient6).to eq("3.00")
      end
      it "should correctly change the ingredient7" do
        @recipe.update(ingredient7: "3.00")
        expect(@recipe.ingredient7).to eq("3.00")
      end
      it "should correctly change the ingredient8" do
        @recipe.update(ingredient8: "3.00")
        expect(@recipe.ingredient8).to eq("3.00")
      end
      it "should correctly change the ingredient9" do
        @recipe.update(ingredient9: "3.00")
        expect(@recipe.ingredient9).to eq("3.00")
      end
      it "should correctly change the ingredient10" do
        @recipe.update(ingredient10: "3.00")
        expect(@recipe.ingredient10).to eq("3.00")
      end
      it "should correctly change the ingredient11" do
        @recipe.update(ingredient11: "3.00")
        expect(@recipe.ingredient11).to eq("3.00")
      end
      it "should correctly change the ingredient12" do
        @recipe.update(ingredient12: "3.00")
        expect(@recipe.ingredient12).to eq("3.00")
      end
      it "should correctly change the ingredient13" do
        @recipe.update(ingredient13: "3.00")
        expect(@recipe.ingredient13).to eq("3.00")
      end
      it "should correctly change the ingredient14" do
        @recipe.update(ingredient14: "3.00")
        expect(@recipe.ingredient14).to eq("3.00")
      end
      it "should correctly change the ingredient15" do
        @recipe.update(ingredient15: "3.00")
        expect(@recipe.ingredient15).to eq("3.00")
      end
      it "should correctly change the ingredient16" do
        @recipe.update(ingredient16: "3.00")
        expect(@recipe.ingredient16).to eq("3.00")
      end
      it "should correctly change the ingredient17" do
        @recipe.update(ingredient17: "3.00")
        expect(@recipe.ingredient17).to eq("3.00")
      end
      it "should correctly change the ingredient18" do
        @recipe.update(ingredient18: "3.00")
        expect(@recipe.ingredient18).to eq("3.00")
      end
      it "should correctly change the ingredient19" do
        @recipe.update(ingredient19: "3.00")
        expect(@recipe.ingredient19).to eq("3.00")
      end
      it "should correctly change the ingredient20" do
        @recipe.update(ingredient20: "3.00")
        expect(@recipe.ingredient20).to eq("3.00")
      end
      it "should correctly change the ingredient21" do
        @recipe.update(ingredient21: "3.00")
        expect(@recipe.ingredient21).to eq("3.00")
      end
      it "should correctly change the ingredient22" do
        @recipe.update(ingredient22: "3.00")
        expect(@recipe.ingredient22).to eq("3.00")
      end
      it "should correctly change the quantity1" do
        @recipe.update(quantity1: "3.00")
        expect(@recipe.quantity1).to eq("3.00")
      end
      it "should correctly change the quantity2" do
        @recipe.update(quantity2: "3.00")
        expect(@recipe.quantity2).to eq("3.00")
      end
      it "should correctly change the quantity3" do
        @recipe.update(quantity3: "3.00")
        expect(@recipe.quantity3).to eq("3.00")
      end
      it "should correctly change the quantity4" do
        @recipe.update(quantity4: "3.00")
        expect(@recipe.quantity4).to eq("3.00")
      end
      it "should correctly change the quantity5" do
        @recipe.update(quantity5: "3.00")
        expect(@recipe.quantity5).to eq("3.00")
      end
      it "should correctly change the quantity6" do
        @recipe.update(quantity6: "3.00")
        expect(@recipe.quantity6).to eq("3.00")
      end
      it "should correctly change the quantity7" do
        @recipe.update(quantity7: "3.00")
        expect(@recipe.quantity7).to eq("3.00")
      end
      it "should correctly change the quantity8" do
        @recipe.update(quantity8: "3.00")
        expect(@recipe.quantity8).to eq("3.00")
      end
      it "should correctly change the quantity9" do
        @recipe.update(quantity9: "3.00")
        expect(@recipe.quantity9).to eq("3.00")
      end
      it "should correctly change the quantity10" do
        @recipe.update(quantity10: "3.00")
        expect(@recipe.quantity10).to eq("3.00")
      end
      it "should correctly change the quantity11" do
        @recipe.update(quantity11: "3.00")
        expect(@recipe.quantity11).to eq("3.00")
      end
      it "should correctly change the quantity12" do
        @recipe.update(quantity12: "3.00")
        expect(@recipe.quantity12).to eq("3.00")
      end
      it "should correctly change the quantity13" do
        @recipe.update(quantity13: "3.00")
        expect(@recipe.quantity13).to eq("3.00")
      end
      it "should correctly change the quantity14" do
        @recipe.update(quantity14: "3.00")
        expect(@recipe.quantity14).to eq("3.00")
      end
      it "should correctly change the quantity15" do
        @recipe.update(quantity15: "3.00")
        expect(@recipe.quantity15).to eq("3.00")
      end
      it "should correctly change the quantity16" do
        @recipe.update(quantity16: "3.00")
        expect(@recipe.quantity16).to eq("3.00")
      end
      it "should correctly change the quantity17" do
        @recipe.update(quantity17: "3.00")
        expect(@recipe.quantity17).to eq("3.00")
      end
      it "should correctly change the quantity18" do
        @recipe.update(quantity18: "3.00")
        expect(@recipe.quantity18).to eq("3.00")
      end
      it "should correctly change the quantity19" do
        @recipe.update(quantity19: "3.00")
        expect(@recipe.quantity19).to eq("3.00")
      end
      it "should correctly change the quantity20" do
        @recipe.update(quantity20: "3.00")
        expect(@recipe.quantity20).to eq("3.00")
      end
      it "should correctly change the quantity21" do
        @recipe.update(quantity21: "3.00")
        expect(@recipe.quantity21).to eq("3.00")
      end
      it "should correctly change the quantity22" do
        @recipe.update(quantity22: "3.00")
        expect(@recipe.quantity22).to eq("3.00")
      end
      it "should correctly change the instruction1" do
        @recipe.update(instruction1: "3.00")
        expect(@recipe.instruction1).to eq("3.00")
      end
      it "should correctly change the instruction2" do
        @recipe.update(instruction2: "3.00")
        expect(@recipe.instruction2).to eq("3.00")
      end
      it "should correctly change the instruction3" do
        @recipe.update(instruction3: "3.00")
        expect(@recipe.instruction3).to eq("3.00")
      end
      it "should correctly change the instruction4" do
        @recipe.update(instruction4: "3.00")
        expect(@recipe.instruction4).to eq("3.00")
      end
      it "should correctly change the instruction5" do
        @recipe.update(instruction5: "3.00")
        expect(@recipe.instruction5).to eq("3.00")
      end
      it "should correctly change the instruction6" do
        @recipe.update(instruction6: "3.00")
        expect(@recipe.instruction6).to eq("3.00")
      end
      it "should correctly change the instruction7" do
        @recipe.update(instruction7: "3.00")
        expect(@recipe.instruction7).to eq("3.00")
      end
      it "should correctly change the instruction8" do
        @recipe.update(instruction8: "3.00")
        expect(@recipe.instruction8).to eq("3.00")
      end
      it "should correctly change the instruction9" do
        @recipe.update(instruction9: "3.00")
        expect(@recipe.instruction9).to eq("3.00")
      end
      it "should correctly change the instruction10" do
        @recipe.update(instruction10: "3.00")
        expect(@recipe.instruction10).to eq("3.00")
      end
      it "should correctly change the instruction11" do
        @recipe.update(instruction11: "3.00")
        expect(@recipe.instruction11).to eq("3.00")
      end
      it "should correctly change the instruction12" do
        @recipe.update(instruction12: "3.00")
        expect(@recipe.instruction12).to eq("3.00")
      end
      it "should correctly change the instruction13" do
        @recipe.update(instruction13: "3.00")
        expect(@recipe.instruction13).to eq("3.00")
      end
      it "should correctly change the instruction14" do
        @recipe.update(instruction14: "3.00")
        expect(@recipe.instruction14).to eq("3.00")
      end
      it "should correctly change the instruction15" do
        @recipe.update(instruction15: "3.00")
        expect(@recipe.instruction15).to eq("3.00")
      end
      it "should correctly change the instruction16" do
        @recipe.update(instruction16: "3.00")
        expect(@recipe.instruction16).to eq("3.00")
      end
      it "should correctly change the instruction17" do
        @recipe.update(instruction17: "3.00")
        expect(@recipe.instruction17).to eq("3.00")
      end
      it "should correctly change the instruction18" do
        @recipe.update(instruction18: "3.00")
        expect(@recipe.instruction18).to eq("3.00")
      end
      it "should correctly change the instruction19" do
        @recipe.update(instruction19: "3.00")
        expect(@recipe.instruction19).to eq("3.00")
      end
      it "should correctly change the instruction20" do
        @recipe.update(instruction20: "3.00")
        expect(@recipe.instruction20).to eq("3.00")
      end
    end

    context "#destroy" do
      it "should reduce the total entries in the database" do
        @recipe.save
        expect {
          @recipe.destroy
        }.to change(Recipe, :count).by(-1)
      end
      it "should remove recipe from the database" do
        @recipe.save
        @recipe.destroy
        expect(Recipe.first).to eq(nil)
      end
    end

  end
end
