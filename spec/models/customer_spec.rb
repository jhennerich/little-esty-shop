require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe "validations" do
    it { should validate_presence_of :first_name }
    it { should validate_presence_of :last_name }
  end
  describe "relationships" do
    it { should have_many :invoices }
  end

  describe "class methods" do
    it "::top_five_customers" do
      customer_1 = Customer.create!(first_name: "James", last_name: "Murdoch")
      customer_2 = Customer.create!(first_name: "Jim", last_name: "Murdoch")
      customer_3 = Customer.create!(first_name: "John", last_name: "Murdoch")
      customer_4 = Customer.create!(first_name: "Jordan", last_name: "Murdoch")
      customer_5 = Customer.create!(first_name: "Jerremiah", last_name: "Murdoch")
      customer_6 = Customer.create!(first_name: "Jeffry", last_name: "Murdoch")

      invoice_1 = customer_1.invoices.create!(status: 0)
      invoice_2 = customer_1.invoices.create!(status: 0)
      invoice_3 = customer_2.invoices.create!(status: 0)
      invoice_4 = customer_2.invoices.create!(status: 0)
      invoice_5 = customer_3.invoices.create!(status: 0)
      invoice_6 = customer_4.invoices.create!(status: 0)
      invoice_7 = customer_5.invoices.create!(status: 0)
      invoice_8 = customer_6.invoices.create!(status: 0)

      transaction_1 = invoice_1.transactions.create!(credit_card_number: 123456, result: "success")
      transaction_2 = invoice_2.transactions.create!(credit_card_number: 123456, result: "success")
      transaction_3 = invoice_3.transactions.create!(credit_card_number: 123456, result: "success")
      transaction_4 = invoice_4.transactions.create!(credit_card_number: 123456, result: "success")
      transaction_5 = invoice_5.transactions.create!(credit_card_number: 123456, result: "success")
      transaction_6 = invoice_6.transactions.create!(credit_card_number: 123456, result: "success")
      transaction_7 = invoice_7.transactions.create!(credit_card_number: 123456, result: "success")
      transaction_8 = invoice_7.transactions.create!(credit_card_number: 123456, result: "success")
      transaction_9 = invoice_8.transactions.create!(credit_card_number: 123456, result: "failed")
      transaction_10 = invoice_8.transactions.create!(credit_card_number: 123456, result: "failed")
      transaction_11 = invoice_8.transactions.create!(credit_card_number: 123456, result: "failed")
      transaction_12 = invoice_8.transactions.create!(credit_card_number: 123456, result: "failed")

      expect(Customer.top_five_customers.include?(customer_1)).to eq(true)
      expect(Customer.top_five_customers.include?(customer_2)).to eq(true)
      expect(Customer.top_five_customers.include?(customer_3)).to eq(true)
      expect(Customer.top_five_customers.include?(customer_4)).to eq(true)
      expect(Customer.top_five_customers.include?(customer_5)).to eq(true)
      expect(Customer.top_five_customers.include?(customer_6)).to eq(false)
    end
  end

  describe "instance methods" do
    it "#full_name" do
      customer = Customer.create(first_name: "Bob", last_name: "Ross")
      expect(customer.full_name).to eq("Bob Ross")
    end

    it "#succsessful_transaction_count" do
      customer_1 = Customer.create!(first_name: "James", last_name: "Murdoch")
      invoice_1 = customer_1.invoices.create!(status: 0)
      invoice_2 = customer_1.invoices.create!(status: 0)
      transaction_1 = invoice_1.transactions.create!(credit_card_number: 123456, result: "success")
      transaction_2 = invoice_2.transactions.create!(credit_card_number: 123456, result: "success")
      transaction_3 = invoice_1.transactions.create!(credit_card_number: 123456, result: "failed")
      transaction_4 = invoice_2.transactions.create!(credit_card_number: 123456, result: "failed")

      expect(customer_1.succsessful_transaction_count).to eq(2)
    end
  end
end
