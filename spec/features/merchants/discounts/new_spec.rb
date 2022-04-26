require 'rails_helper'

RSpec.describe 'merchant discounts new page' do

  it 'links from the merchants discounts index page' do
    merchant = Merchant.create!(name: "Maytig Applicance")
    visit "/merchants/#{merchant.id}/bulk_discounts/"

    click_on "Create A New Discount"

    expect(current_path).to eq("/merchants/#{merchant.id}/bulk_discounts/new")
  end

end
