class ChangeColumnTypesAddress < ActiveRecord::Migration[5.1]
  def up
    # remove_column :spree_zone_members, :zoneable_id
    # remove_column :spree_zone_members, :zoneable_type
    # add_column :spree_zone_members, :zoneable, :text
    # add_column :spree_zones, :zone_membs, :text
    remove_column :spree_addresses, :state_id
    # add_column :spree_zones, :states, :text
    # add_column :spree_zones, :countries, :text
    add_column :spree_zones, :members, :text
    add_column :spree_addresses, :country, :text
    add_column :spree_addresses, :state, :text
    # add_column :spree_zones, :zone_membs, :text
    # rename_column :spree_prices, :country_iso, :country
    # change_column :spree_prices, :country, :string
    # rename_column :spree_addresses, :country_id, :country
    # change_column :spree_addresses, :country, :string
    # rename_column :spree_addresses, :state_id, :state
    # change_column :spree_addresses, :state, :string
  end

  def down
    # change_column :spree_addresses, :country, :string
    # change_column :spree_addresses, :state, :string
  end
end
