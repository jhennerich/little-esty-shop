class InvoiceItem < ApplicationRecord

  validates_presence_of :quantity
  validates_presence_of :unit_price
  validates_presence_of :status
  validates_presence_of :item_id
  validates_presence_of :invoice_id

  belongs_to :item
  belongs_to :invoice

  enum status: {pending: 0, packaged: 1, shipped: 2}

  def get_discount
    item = Item.find(item_id)
    all_discounts = Merchant.find(item.merchant_id).bulk_discounts.order(:discount)
    discount = nil
    all_discounts.each { |bulk_discount| discount = bulk_discount if self.quantity >= bulk_discount.threshold }
    return discount
  end
end
