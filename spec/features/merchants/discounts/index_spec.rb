require 'rails_helper'

RSpec.describe "merchants discounts index page" do

  it "links from the merchant's dashboard" do
    merchant_1 = Merchant.create!(name: "General Paper Inc")
    discount_1 = merchant_1.bulk_discounts.create!(threshold: 12, discount: 5.0)
    discount_2 = merchant_1.bulk_discounts.create!(threshold: 50, discount: 10.0)

    visit "/merchants/#{merchant_1.id}/dashboard/"
    click_on "View My Discounts"

    expect(current_path).to eq("/merchants/#{merchant_1.id}/bulk_discounts")
    expect(page).to have_content("5.0% when a customer buys 12 or more items")
    expect(page).to have_content("10.0% when a customer buys 50 or more items")

    within("#merchant-discounts-index-discount-#{discount_1.id}") do
      click_on "View Discount Details"
    end

    expect(current_path).to eq("/merchants/#{merchant_1.id}/bulk_discounts/#{discount_1.id}/")
  end

  it 'provides buttons to delete discounts individually' do
    merchant_1 = Merchant.create!(name: "General Paper Inc")
    discount_1 = merchant_1.bulk_discounts.create!(threshold: 12, discount: 5.0)
    discount_2 = merchant_1.bulk_discounts.create!(threshold: 50, discount: 10.0)

    visit "/merchants/#{merchant_1.id}/bulk_discounts/"
    within("#merchant-discounts-index-discount-#{discount_1.id}") do
      click_on "Delete Discount"
    end
    expect(current_path).to eq("/merchants/#{merchant_1.id}/bulk_discounts/")
    expect(page).not_to have_content("5.0% when a customer buys 12 or more items")
    expect(page).to have_content("10.0% when a customer buys 50 or more items")

  end

end
