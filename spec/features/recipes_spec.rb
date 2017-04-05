# require 'rails_helper'
#
# RSpec.feature "Products Integration Testing", type: :feature, js: true do
#     describe "Visiting the root/index product list" do
#       let!(:product) { create :product }
#
#       it "should list all product names" do
#         visit root_path
#         expect(page).to have_content(product.name)
#       end
#
#       it "should list all product prices" do
#         visit root_path
#         expect(page).to have_content(product.price)
#       end
#
#       it "should have an image" do
#         visit root_path
#         expect(page).to have_selector(:css, "img")
#       end
#     end
#
#     describe "Visiting the control panel as an admin" do
#       before(:each) do
#         @admin = User.create(email: "tim@tim.com", password: "timtim", admin: true)
#         visit admin_path
#         fill_in 'user[email]', with: @admin.email
#         fill_in 'user[password]', with: @admin.password
#         click_button 'Log in'
#       end
#
#       let!(:product) { create :product }
#
#       it "should list all product names" do
#         visit admin_path
#         expect(page).to have_content(product.name)
#       end
#
#       it "should list all product prices" do
#         visit admin_path
#         expect(page).to have_content(product.price)
#       end
#
#       it "should list all product quantities" do
#         visit admin_path
#         expect(page).to have_content(product.quantity)
#       end
#
#       it "should have links to edit all of the products" do
#         visit admin_path
#         expect(page).to have_link('Edit', href: edit_product_path(product))
#       end
#
#       it "should have links to delete all of the products" do
#         visit admin_path
#         expect(page).to have_link('Delete', href: product_path(product))
#       end
#     end
#
#     describe "Visiting the control panel as an regular user" do
#       before(:each) do
#         @reg_user = User.create(email: "tom@tom.com", password: "tomtom", admin: false)
#         visit admin_path
#         fill_in 'user[email]', with: @reg_user.email
#         fill_in 'user[password]', with: @reg_user.password
#         click_button 'Log in'
#       end
#
#       let!(:product) { create :product }
#
#       it "should redirect to the root path" do
#         visit admin_path
#         expect(page).to have_content("Welcome to Pop Shoppe")
#       end
#     end
#
#     describe "Visiting a show page" do
#       let!(:product) { create :product }
#
#       it "should show the product's name" do
#         visit product_path(product)
#         expect(page).to have_content(product.name)
#       end
#
#       it "should show the product's price" do
#         visit product_path(product)
#         expect(page).to have_content(product.price)
#       end
#
#       it "should show the product's quantity" do
#         visit product_path(product)
#         expect(page).to have_content(product.quantity)
#       end
#
#       it "should show the product's description" do
#         visit product_path(product)
#         expect(page).to have_content(product.description)
#       end
#     end
# end
