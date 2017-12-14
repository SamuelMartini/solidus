class UseCarmenInZoneMembers < ActiveRecord::Migration[5.1]
  def change
    remove_column :spree_zone_members, :zoneable_id
    add_column :spree_zone_members, :zoneable, :text
  end
end
