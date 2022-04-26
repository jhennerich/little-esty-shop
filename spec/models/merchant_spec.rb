require 'rails_helper'
require 'time'

RSpec.describe Merchant, type: :model do
  describe "validations" do
    it { should validate_presence_of :name}
  end
  describe "relationships" do
     it { should have_many :items }
  end

  describe 'instance methods' do
    it '#most_popular_items' do
      merchant1 = create(:merchant)
      customer1 = create(:customer)

      invoice1 = create(:invoice, customer: customer1, status: 1)
      invoice2 = create(:invoice, customer: customer1, status: 1)

      transaction1 = create(:transaction, invoice: invoice1, result: 'success')
      transaction2 = create(:transaction, invoice: invoice2, result: 'failed')

      item1 = create(:item, merchant: merchant1, unit_price: 1)
      item2 = create(:item, merchant: merchant1, unit_price: 2)
      item3 = create(:item, merchant: merchant1, unit_price: 3)
      item4 = create(:item, merchant: merchant1, unit_price: 4)
      item5 = create(:item, merchant: merchant1, unit_price: 5)
      item6 = create(:item, merchant: merchant1, unit_price: 6)

      invoice_item1 = create(:invoice_item, item: item1, invoice: invoice1, quantity: 1, unit_price: 300) #300 rev
      invoice_item2 = create(:invoice_item, item: item2, invoice: invoice1, quantity: 2, unit_price: 10) #20 rev
      invoice_item3 = create(:invoice_item, item: item3, invoice: invoice1, quantity: 3, unit_price: 10) #30 rev
      invoice_item4 = create(:invoice_item, item: item4, invoice: invoice1, quantity: 1, unit_price: 10) #10 rev
      invoice_item5 = create(:invoice_item, item: item5, invoice: invoice1, quantity: 5, unit_price: 10) #50 rev
      invoice_item6 = create(:invoice_item, item: item6, invoice: invoice2, quantity: 6, unit_price: 10) #60 rev

      expect(merchant1.most_popular_items[0]).to eq(item1)
      expect(merchant1.most_popular_items[1]).to eq(item5)
      expect(merchant1.most_popular_items[2]).to eq(item3)
      expect(merchant1.most_popular_items[3]).to eq(item2)
      expect(merchant1.most_popular_items[4]).to eq(item4)
    end

    it "#unshipped_invoice_items returns a merchant's invoice items with unshipped status" do
      merchant = Merchant.create(name: "Need a Merchant")
      item_1 = merchant.items.create!(name: "spoon", description: "stamped stainless steel, not deburred", unit_price: 80, status: 1, merchant_id: merchant.id)
      item_2 = merchant.items.create!(name: "fork", description: "stamped stainless steel, not deburred", unit_price: 90, status: 1, merchant_id: merchant.id)
      customer_1 = Customer.create(first_name: "Max", last_name: "Powers")
      invoice_1 = customer_1.invoices.create!(status: 0)
      invoice_2 = customer_1.invoices.create!(status: 0)
      association_1 = InvoiceItem.create!(item_id: item_1.id, invoice_id: invoice_1.id, quantity: 3, unit_price:75, status:0)
      association_2 = InvoiceItem.create!(item_id: item_2.id, invoice_id: invoice_1.id, quantity: 3, unit_price:77, status:1)
      association_2 = InvoiceItem.create!(item_id: item_1.id, invoice_id: invoice_2.id, quantity: 3, unit_price:77, status:2)

      expected_collection = merchant.unshipped_invoice_items
      expect(expected_collection.length).to eq(2)
      expect(expected_collection.pluck(:name).include?(item_1.name)).to eq(true)
      expect(expected_collection.pluck(:name).include?(item_2.name)).to eq(true)
    end

    it "#total_rev returns the all-time total revenue for a merchant" do
      merchant_3 = Merchant.create!(name: "Le Petit Marchet")

      item_1 = merchant_3.items.create!(name: "paper towel", description: "6 pk extra adsorpbant", status: 1, unit_price: 899)
      item_2 = merchant_3.items.create!(name: "paper towel", description: "12 pk extra adsorpbant", status: 1, unit_price: 1099)
      item_3 = merchant_3.items.create!(name: "paper towel", description: "single extra adsorpbant", status: 1, unit_price: 299)
      item_4 = merchant_3.items.create!(name: "disposible napkins", description: "1000 ct pre-folded unbleached", status: 1, unit_price: 1099)

      customer_1 = Customer.create!(first_name:"Markus", last_name: "Vance")

      invoice_1 = customer_1.invoices.create!(status: 1)
      invoice_2 = customer_1.invoices.create!(status: 1)
      invoice_3 = customer_1.invoices.create!(status: 1)

      invoice_item_1 = InvoiceItem.create!(invoice_id: invoice_1.id, item_id: item_1.id, quantity: 5, unit_price: 100, status: 0)
      invoice_item_2 = InvoiceItem.create!(invoice_id: invoice_2.id, item_id: item_2.id, quantity: 5, unit_price: 100, status: 1)
      invoice_item_3 = InvoiceItem.create!(invoice_id: invoice_3.id, item_id: item_3.id, quantity: 5, unit_price: 100, status: 2)

      transaction_1 = invoice_1.transactions.create!(credit_card_number: 123456, result: "success")
      transaction_2 = invoice_2.transactions.create!(credit_card_number: 223456, result: "success")
      transaction_3 = invoice_2.transactions.create!(credit_card_number: 323456, result: "failed")
      transaction_4 = invoice_3.transactions.create!(credit_card_number: 423456, result: "failed")

      # invoices 1 and 2 should count, invoice 3 should not since it has no successful transactions

      actual = merchant_3.total_rev
      expect(actual).to eq(1000)
    end

    it "#best_date_by_revenue returns best date of revenue for a merchant" do
      merchant_3 = Merchant.create!(name: "Le Petit Marchet")

      item_1 = merchant_3.items.create!(name: "paper towel", description: "6 pk extra adsorpbant", status: 1, unit_price: 899)
      item_2 = merchant_3.items.create!(name: "paper towel", description: "12 pk extra adsorpbant", status: 1, unit_price: 1099)
      item_3 = merchant_3.items.create!(name: "paper towel", description: "single extra adsorpbant", status: 1, unit_price: 299)
      item_4 = merchant_3.items.create!(name: "disposible napkins", description: "1000 ct pre-folded unbleached", status: 1, unit_price: 1099)

      customer_1 = Customer.create!(first_name:"Markus", last_name: "Vance")

      invoice_1 = customer_1.invoices.create!(status: 1, created_at: Time.parse("2020.05.06"))
      invoice_2 = customer_1.invoices.create!(status: 1, created_at: Time.parse("2020.05.07"))
      invoice_3 = customer_1.invoices.create!(status: 1, created_at: Time.parse("2020.05.07"))
      invoice_4 = customer_1.invoices.create!(status: 1, created_at: Time.parse("2020.05.08"))

      invoice_item_1 = InvoiceItem.create!(invoice_id: invoice_1.id, item_id: item_1.id, quantity: 7, unit_price: 100, status: 0)
      invoice_item_2 = InvoiceItem.create!(invoice_id: invoice_2.id, item_id: item_2.id, quantity: 5, unit_price: 100, status: 1)
      invoice_item_3 = InvoiceItem.create!(invoice_id: invoice_3.id, item_id: item_3.id, quantity: 4, unit_price: 100, status: 2)
      invoice_item_4 = InvoiceItem.create!(invoice_id: invoice_4.id, item_id: item_4.id, quantity: 10, unit_price: 100, status: 2) # Highest grossing day but no successful transactions

      transaction_1 = invoice_1.transactions.create!(credit_card_number: 123456, result: "success")
      transaction_2 = invoice_2.transactions.create!(credit_card_number: 223456, result: "success")
      transaction_3 = invoice_2.transactions.create!(credit_card_number: 323456, result: "failed")
      transaction_4 = invoice_3.transactions.create!(credit_card_number: 323456, result: "success")
      transaction_5 = invoice_4.transactions.create!(credit_card_number: 423456, result: "failed")

      actual = merchant_3.best_date_by_revenue
      expect(actual).to eq({"2020.05.07" => 900})
    end

    it "#best_date_formatted" do
      merchant_3 = Merchant.create!(name: "Le Petit Marchet")

      item_1 = merchant_3.items.create!(name: "paper towel", description: "6 pk extra adsorpbant", status: 1, unit_price: 899)
      item_2 = merchant_3.items.create!(name: "paper towel", description: "12 pk extra adsorpbant", status: 1, unit_price: 1099)
      item_3 = merchant_3.items.create!(name: "paper towel", description: "single extra adsorpbant", status: 1, unit_price: 299)
      item_4 = merchant_3.items.create!(name: "disposible napkins", description: "1000 ct pre-folded unbleached", status: 1, unit_price: 1099)

      customer_1 = Customer.create!(first_name:"Markus", last_name: "Vance")

      invoice_1 = customer_1.invoices.create!(status: 1, created_at: Time.parse("2020.05.06"))
      invoice_2 = customer_1.invoices.create!(status: 1, created_at: Time.parse("2020.05.07"))
      invoice_3 = customer_1.invoices.create!(status: 1, created_at: Time.parse("2020.05.07"))
      invoice_4 = customer_1.invoices.create!(status: 1, created_at: Time.parse("2020.05.08"))

      expect(merchant_3.best_date_formatted).to eq("No sales data")

      invoice_item_1 = InvoiceItem.create!(invoice_id: invoice_1.id, item_id: item_1.id, quantity: 7, unit_price: 100, status: 0)
      invoice_item_2 = InvoiceItem.create!(invoice_id: invoice_2.id, item_id: item_2.id, quantity: 5, unit_price: 100, status: 1)
      invoice_item_3 = InvoiceItem.create!(invoice_id: invoice_3.id, item_id: item_3.id, quantity: 4, unit_price: 100, status: 2)
      invoice_item_4 = InvoiceItem.create!(invoice_id: invoice_4.id, item_id: item_4.id, quantity: 10, unit_price: 100, status: 2) # Highest grossing day but no successful transactions

      transaction_1 = invoice_1.transactions.create!(credit_card_number: 123456, result: "success")
      transaction_2 = invoice_2.transactions.create!(credit_card_number: 223456, result: "success")
      transaction_3 = invoice_2.transactions.create!(credit_card_number: 323456, result: "failed")
      transaction_4 = invoice_3.transactions.create!(credit_card_number: 323456, result: "success")
      transaction_5 = invoice_4.transactions.create!(credit_card_number: 423456, result: "failed")

      expect(merchant_3.best_date_formatted).to eq("Thursday, May 07 2020")
    end

    it '#find_discount returns discount information if owned by merchant' do
      merchant1 = Merchant.create!(name: "Bell Burrito")
      discount1 = merchant1.bulk_discounts.create!(threshold: 40, discount: 10)
      merchant2 = Merchant.create!(name: "Guac Jock Sports Tacos")
      discount2 = merchant2.bulk_discounts.create!(threshold: 20, discount: 3)
      expect(merchant1.find_discount(discount1.id)).to eq(discount1)
      expect(merchant1.find_discount(discount2.id)).to eq(nil)
    end
  end

  describe 'class methods' do
    before :each do
      @merchant1 = Merchant.create!(name: "Pabu")
      @merchant2 = Merchant.create!(name: "Loki")
      @merchant3 = Merchant.create!(name: "Thor")
      @merchant4 = Merchant.create!(name: "Ian")
      @merchant5 = Merchant.create!(name: "Joe")
      @merchant6 = Merchant.create!(name: "John")

      @item1 = @merchant1.items.create!(name: "Comic", description: "Spider-Man", unit_price: 200, status: 1)
      @item2 = @merchant2.items.create!(name: "Action figure", description: "Deku", unit_price: 800, status: 1)
      @item3 = @merchant2.items.create!(name: "One Piece", description: "Rare", unit_price: 500, status: 1)
      @item4 = @merchant3.items.create!(name: "Hunter card", description: "Useful", unit_price: 300, status: 1)
      @item5 = @merchant4.items.create!(name: "Kunai", description: "Minatos", unit_price: 100, status: 1)
      @item6 = @merchant5.items.create!(name: "ODM gear", description: "Advance technology", unit_price: 300, status: 1)
      @item7 = @merchant5.items.create!(name: "Zenitsu", description: "Awsome sword", unit_price: 500, status: 1)
      @item8 = @merchant6.items.create!(name: "Elucidator", description: "Kiritos sword", unit_price: 10, status: 1)

      @customer1 = Customer.create!(first_name: "Customer", last_name: "One")

      @invoice1 = @customer1.invoices.create!(status: 2)
      @invoice2 = @customer1.invoices.create!(status: 2)
      @invoice3 = @customer1.invoices.create!(status: 2)
      @invoice4 = @customer1.invoices.create!(status: 2)
      @invoice5 = @customer1.invoices.create!(status: 2)
      @invoice6 = @customer1.invoices.create!(status: 2)

      @ii1 = InvoiceItem.create!(invoice_id: @invoice1.id, item_id: @item1.id, quantity: 5, unit_price: 200, status: 1)
      @ii1 = InvoiceItem.create!(invoice_id: @invoice2.id, item_id: @item2.id, quantity: 5, unit_price: 800, status: 1)
      @ii1 = InvoiceItem.create!(invoice_id: @invoice2.id, item_id: @item3.id, quantity: 5, unit_price: 500, status: 1)
      @ii1 = InvoiceItem.create!(invoice_id: @invoice3.id, item_id: @item4.id, quantity: 5, unit_price: 300, status: 1)
      @ii1 = InvoiceItem.create!(invoice_id: @invoice4.id, item_id: @item5.id, quantity: 5, unit_price: 500, status: 1)
      @ii1 = InvoiceItem.create!(invoice_id: @invoice5.id, item_id: @item6.id, quantity: 10, unit_price: 500, status: 1)
      @ii1 = InvoiceItem.create!(invoice_id: @invoice5.id, item_id: @item7.id, quantity: 10, unit_price: 500, status: 1)
      @ii1 = InvoiceItem.create!(invoice_id: @invoice6.id, item_id: @item8.id, quantity: 1, unit_price: 100, status: 1)

      @transaction1 = Transaction.create!(credit_card_number: 203942, result: 'success', invoice_id: @invoice1.id)
      @transaction2 = Transaction.create!(credit_card_number: 230948, result: 'success', invoice_id: @invoice2.id)
      @transaction3 = Transaction.create!(credit_card_number: 234092, result: 'success', invoice_id: @invoice3.id)
      @transaction4 = Transaction.create!(credit_card_number: 230429, result: 'success', invoice_id: @invoice4.id)
      @transaction5 = Transaction.create!(credit_card_number: 102938, result: 'failed', invoice_id: @invoice5.id)
      @transaction6 = Transaction.create!(credit_card_number: 879799, result: 'success', invoice_id: @invoice6.id)
    end

    it '#top_5_merchants returns based on total rev' do
      expect(Merchant.top_5_merchants).to eq([@merchant2, @merchant4, @merchant3, @merchant1, @merchant6])
    end

  end
end
