require 'rails_helper'

RSpec.describe 'merchant discounts new page' do

  it 'links from the merchants discounts index page' do
    merchant = Merchant.create!(name: "Maytig Applicance")
    visit "/merchants/#{merchant.id}/bulk_discounts/"

    click_on "Create A New Discount"

    expect(current_path).to eq("/merchants/#{merchant.id}/bulk_discounts/new")

    fill_in :discount, with: "12.5"
    fill_in :threshold, with: "25"
    click_on "Create Discount"

    expect(current_path).to eq("/merchants/#{merchant.id}/bulk_discounts/")

    expect(page).to have_content("12.5% when a customer buys 25 or more items")
  end

end
