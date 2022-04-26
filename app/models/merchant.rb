class Merchant < ApplicationRecord
  validates_presence_of :name

  has_many :items
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items
  has_many :customers, through: :invoices
  has_many :transactions, through: :invoices
  has_many :bulk_discounts

  enum status: {disabled: 0, enabled: 1}

  def most_popular_items
    items.joins(invoices: :transactions)
    .select('items.*, sum(invoice_items.quantity * invoice_items.unit_price) as total_revenue')
    .where('transactions.result = ?', 'success')
    .group('items.id')
    .order('total_revenue desc')
    .limit(5)
  end

  def unshipped_invoice_items
    items.select('items.name, invoice_items.invoice_id, invoice_items.status, invoice_items.id AS invoice_item_id, invoices.created_at AS invoice_created_at')
    .where("invoice_items.status = 0 OR invoice_items.status = 1")
    .joins(:invoices)
    .order('invoices.created_at')
  end

  def best_date_by_revenue
    invoice_sums = invoices.joins(:transactions)
    .where('transactions.result = ?', 'success')
    .where(status: "completed")
    .select('invoices.*, sum(invoice_items.quantity * invoice_items.unit_price) as revenue')
    .group('invoices.id')
    .order('revenue DESC, invoices.created_at')
    sums_by_date = Hash.new(0)
    invoice_sums.each { |invoice| sums_by_date[invoice.created_at.strftime("%Y.%m.%d")] += invoice.revenue}
    max = {"0000.01.01" => 0}
    sums_by_date.each_pair { |date, sum| max = {date => sum} if sum > max.values[0] || (sum == date && Time.parse(date) > Time.parse(max.keys[0])) }
    return max
  end

  def best_date_formatted
    if best_date_by_revenue.values.first != 0
      return Time.parse(best_date_by_revenue.keys.first).strftime("%A, %B %d %Y")
    else
      return "No sales data"
    end
  end

  def self.top_5_merchants
    joins(:invoice_items, :transactions)
    .where('result = ?', 'success')
    .select('merchants.*, sum(invoice_items.unit_price * invoice_items.quantity) AS revenue')
    .group('merchants.id')
    .limit(5)
    .order('revenue DESC')
  end

  def total_rev
    invoices
    .joins(:transactions)
    .where("transactions.result = 'success'")
    .sum("invoice_items.unit_price * invoice_items.quantity")
  end

  def find_discount(discount_id)
    discount = BulkDiscount.find(discount_id)
    if discount.merchant_id == self.id
      return discount
    end
  end
end
