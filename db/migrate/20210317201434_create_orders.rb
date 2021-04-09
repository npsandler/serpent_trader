class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.string :coin_type
      t.integer :purchase_price
      t.integer :coin_volume
      t.integer :take_profit
      t.integer :stop_loss
      t.boolean :is_closed, default: false
      t.datetime :closed_date, null: true
      t.string :external_order_id
      t.string :loss_limit_order_id
      t.string :take_profit_order_id

      t.timestamps
    end
  end
end
