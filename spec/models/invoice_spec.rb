require 'rails_helper'
require 'time'

RSpec.describe Invoice, type: :model do
  describe "validations" do
    it { should validate_presence_of :status}
    it { should validate_presence_of :customer_id }
  end
  describe "relationships" do
     it { should belong_to :customer }
     it { should have_many :transactions }
  end

  describe 'instance methods' do
    before :each do
      @merchant1 = Merchant.create!(name: "Pabu")

      @item1 = Item.create!(name: "Brush", description: "Brushy", unit_price: 10, merchant_id: @merchant1.id)
      @item2 = Item.create!(name: "Peanut Butter", description: "Yummy", unit_price: 12, merchant_id: @merchant1.id)

      @customer1 = Customer.create!(first_name: "Loki", last_name: "R")

      @invoice1 = @customer1.invoices.create!(status: "completed")

      @ii1 = InvoiceItem.create!(invoice_id: @invoice1.id, item_id: @item1.id, status: 1, quantity: 20, unit_price: 10)
      @ii2 = InvoiceItem.create!(invoice_id: @invoice1.id, item_id: @item2.id, status: 1, quantity: 5, unit_price: 12)
    end

    it "returns total revenue from all items in invoice" do
      expect(@invoice1.total_rev).to eq(260)
    end


    it "#format_time returns date time as 'Weekday, Month Day##, Year####'" do
      customer = Customer.create!(last_name:"Ross", first_name:"Bob")
      invoice = customer.invoices.create(status: 1, created_at: Time.parse("2022.04.25"))
      expect(invoice.format_time).to eq( "Monday, April 25, 2022")
    end
  end

  describe 'class methods' do
    it "'::pending_invoices' returns invoices that are still pending status" do
      customer = Customer.create!(last_name:"Ross", first_name:"Bob")
      invoice1 = customer.invoices.create(status: 1, created_at: Time.parse("2022.04.25"))
      invoice2 = customer.invoices.create(status: 2)
      invoice3 = customer.invoices.create(status: 0)
      expect(customer.invoices.pending_invoices).to eq([invoice3])
    end

  end
end
