require 'rails_helper'

RSpec.describe 'Merchants discounts edit' do

  it "links from show page to a pre-filled form" do
    merchant_1 = Merchant.create!(name: "General Paper Inc")
    discount_1 = merchant_1.bulk_discounts.create!(threshold: 12, discount: 5.0)
    discount_2 = merchant_1.bulk_discounts.create!(threshold: 50, discount: 10.0)

    visit "/merchants/#{merchant_1.id}/bulk_discounts/#{discount_1.id}"

    click_on "Edit Discount"

    expect(current_path).to eq("/merchants/#{merchant_1.id}/bulk_discounts/#{discount_1.id}/edit/")
    expect(page).to have_field(:discount, with: 5.0)
    expect(page).to have_field(:threshold, with: 12)

    fill_in :discount, with: 10.5
    fill_in :threshold, with: 20
    click_on "Update Discount"

    expect(current_path).to eq("/merchants/#{merchant_1.id}/bulk_discounts/#{discount_1.id}/")
    expect(page).to have_content("Discount: 10.5% off item's unit price")
    expect(page).to have_content("Threshold: 20 or more items")
  end

end
