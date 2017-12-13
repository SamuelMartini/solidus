class UseCarmenInAddress < ActiveRecord::Migration[5.1]
  def change
    remove_column :spree_addresses, :state_id
    remove_column :spree_addresses, :country_id
    add_column :spree_addresses, :state, :text
    add_column :spree_addresses, :country, :text
  end
end
