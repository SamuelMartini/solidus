json.cache! address do
  json.(address, *address_attributes)
  json.country do
    if address.country_iso
      json.(address.country, *country_attributes)
    else
      json.nil!
    end
  end
  json.state do
    if address.state_iso
      json.(address.state, *state_attributes)
    else
      json.nil!
    end
  end
end
