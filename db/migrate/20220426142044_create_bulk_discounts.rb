class CreateBulkDiscounts < ActiveRecord::Migration[5.2]
  def change
    create_table :bulk_discounts do |t|
      t.decimal :discount, precision: 5, scale: 2
      t.integer :threshold
      t.references :merchant, foreign_key: true
      t.timestamps
    end
  end
end
