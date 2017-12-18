class CarmenInZones < ActiveRecord::Migration[5.1]
  def change
    remove_column :spree_zone_members, :zoneable_id
    remove_column :spree_zone_members, :zoneable_type
    add_column :spree_zone_members, :country_iso, :string
    add_column :spree_zone_members, :state_iso, :string
  end
end
