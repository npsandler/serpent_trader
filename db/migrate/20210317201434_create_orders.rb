class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.string :coin_type
      t.integer :cost_cents
      t.integer :coin_value
      t.integer :stop_price
      t.boolean :is_closed, default: false
      t.datetime :closed_date, null: true
      t.string :external_order_id

      t.timestamps
    end
  end
end
