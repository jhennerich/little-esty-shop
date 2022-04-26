class BulkDiscount < ApplicationRecord

  # Relations
  belongs_to :merchant

  # Validations
  validates_presence_of :discount
  validates_presence_of :threshold

  # Methods

end
