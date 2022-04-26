equire 'rails_helper'

RSpec.describe "merchants discounts show page" do

  it "shows a discount's information" do
    merchant_1 = Merchant.create!(name: "General Paper Inc")
    discount_1 = merchant_1.bulk_discounts.create!(threshold: 12, discount: 5.0)
    discount_2 = merchant_1.bulk_discounts.create!(threshold: 50, discount: 10.0)

    visit "/merchants/#{merchant_1.id}/discounts/#{discount_1.id}"

    expect(page).to have_content("Threshold: 12 or more items")
    expect(page).to have_content("Discount: 5.0% off item's unit price")

    expect(page).not_to have_content("Threshold: 50 or more items")
    expect(page).not_to have_content("Discount: 10.0% off item's unit price")
  end
end
