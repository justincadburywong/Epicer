require 'rails_helper'

RSpec.describe User, type: :model do
  describe "Model" do
    context 'Validations' do
      it { should validate_presence_of :email}
      it { should validate_presence_of :password}
    end
    context "#save" do
      let(:user) { User.new(email: "tim@tim.com", password: "timtim")}
      it "adds an entry to the db" do
        expect {
          user.save
        }.to change(User, :count).by(1)
      end
      it "does not add an entry without an email to the db" do
        user.email = nil
        expect {
          user.save
        }.not_to change(User, :count)
      end
      it "does not add an entry without a password to the db" do
        user.password = nil
        expect {
          user.save
        }.not_to change(User, :count)
      end
    end
    describe "Signing up" do
      before do
        @user = FactoryGirl.create(:user)
      end
      it "should save a user" do
        expect(@user).to be_valid
      end
    end
  end
end
