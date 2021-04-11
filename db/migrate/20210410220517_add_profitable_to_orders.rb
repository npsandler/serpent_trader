class AddProfitableToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :profit, :boolean, null: true 
  end
end
