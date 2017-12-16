class CarmenInStockLocation < ActiveRecord::Migration[5.1]
  def change
    remove_column :spree_stock_locations, :country_id
    remove_column :spree_stock_locations, :state_id
    add_column :spree_stock_locations, :state_iso, :string
    add_column :spree_stock_locations, :country_iso, :string
  end
end
