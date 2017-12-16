class CarmenInAddress < ActiveRecord::Migration[5.1]
  def change
    remove_column :spree_addresses, :country_id
    remove_column :spree_addresses, :state_id
    add_column :spree_addresses, :country_iso, :string
    add_column :spree_addresses, :state_iso, :string
  end
end
