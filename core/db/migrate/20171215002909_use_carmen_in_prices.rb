class UseCarmenInPrices < ActiveRecord::Migration[5.1]
  def change
    remove_column :spree_prices, :country_iso
    add_column :spree_prices, :country_iso, :string
  end
end
