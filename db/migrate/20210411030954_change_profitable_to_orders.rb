class ChangeProfitableToOrders < ActiveRecord::Migration[5.2]
  def change
    change_column :orders, :profit,  'integer USING CAST(profit AS integer)'
  end
end
