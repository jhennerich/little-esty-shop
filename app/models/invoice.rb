class Invoice < ApplicationRecord
  validates_presence_of :status
  validates_presence_of :customer_id

  belongs_to :customer
  has_many :transactions
end
