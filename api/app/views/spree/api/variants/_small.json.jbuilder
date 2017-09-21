json.cache! [I18n.locale, variant] do
  json.(variant, *variant_attributes)
  json.display_price(variant.display_price.to_s)
  json.options_text(variant.options_text)
  json.track_inventory(variant.should_track_inventory?)
  json.in_stock(variant.in_stock?)
  json.is_backorderable(variant.is_backorderable?)
  json.total_on_hand(variant.total_on_hand)
  json.is_destroyed(variant.destroyed?)
  json.option_values(variant.option_values) do |option_value|
    json.(option_value, *option_value_attributes)
  end
  if Spree::Config.image_adapter
    json.images(variant.images) do |image|
      json.partial!(Spree::Config.image_adapter.jbuilder_image_path, image: image)
    end
  end
end
