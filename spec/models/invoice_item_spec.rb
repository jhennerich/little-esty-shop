require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do
  describe "validations" do
    it { should validate_presence_of :quantity }
    it { should validate_presence_of :unit_price }
    it { should validate_presence_of :status }
    it { should validate_presence_of :item_id }
    it { should validate_presence_of :invoice_id }
  end
  describe "relationships" do
     it { should belong_to :item }
     it { should belong_to :invoice }
  end

  describe "class methods" do

    it "#get_discount returns the current discount" do
      merchant = Merchant.create!(name:"Generic Vendor")
      item1 = merchant.items.create!(name: "plastic fork", description: "black plastic, type 5, recycled, 60 pk", status: 1, unit_price: 500)
      item2 = merchant.items.create!(name: "plastic fork", description: "black plastic, type 5, recycled, 12 pk", status: 1, unit_price: 100)
      item3 = merchant.items.create!(name: "plastic fork", description: "black plastic, type 5, recycled, single", status: 1, unit_price: 10)
      discount3 = merchant.bulk_discounts.create!(threshold: 50, discount: 12)
      discount1 = merchant.bulk_discounts.create!(threshold: 3, discount: 5)
      discount2 = merchant.bulk_discounts.create!(threshold: 10, discount: 8)
      customer = Customer.create!(first_name: "Richard", last_name: "Nixon")
      invoice = customer.invoices.create!(status: 0)
      invoice_item1 = invoice.invoice_items.create!(item_id: item1.id, quantity: 5, unit_price: 500, status: 0)
      invoice_item2 = invoice.invoice_items.create!(item_id: item2.id, quantity: 15, unit_price: 100, status: 0)
      invoice_item3 = invoice.invoice_items.create!(item_id: item3.id, quantity: 75, unit_price: 10, status: 0)

      expect(invoice_item1.get_discount).to eq(discount1)
      expect(invoice_item2.get_discount).to eq(discount2)
      expect(invoice_item3.get_discount).to eq(discount3)
    end

  end
end
