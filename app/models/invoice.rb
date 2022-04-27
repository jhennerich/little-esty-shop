class Invoice < ApplicationRecord

  validates_presence_of :status
  validates_presence_of :customer_id

  belongs_to :customer
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items

  enum status: {"in progress" => 0, "completed" => 1, "cancelled" => 2}

  def self.pending_invoices
    where(status: 0)
    .order(:created_at)
  end

  def format_time
    created_at.strftime('%A, %B %e, %Y')
  end

  def total_rev
    invoice_items.sum("quantity * unit_price")
  end

  def discounted_rev
    sum = 0.0
    all_discounts = BulkDiscount.all.order(:discount)
    invoice_items.each do |invoice_item|
      item_discount = 0.0
      all_discounts.each { |merchant_discount|item_discount = merchant_discount.discount if merchant_discount.threshold <= invoice_item.quantity}
      discounted_item_total = (1-(item_discount/100)) * invoice_item.quantity * invoice_item.unit_price
      sum += discounted_item_total
    end
    return sum
  end
end
