# This file needs to be killed, it only gives little helpful things for people
# too lazy to upgrade, or they keep using old state from the other model.
Carmen::Region.class_eval do
  def to_hash
    { type: type, code: code, name: name, subregions: subregions, parent: parent.code }
  end

  def country
    parent
  end

  def abbr
    code
  end

  def country_iso
    parent.code
  end

  def empty?
    false
  end
end

Carmen::Country.class_eval do
  def iso_code
    # Spree::Deprecation.warn('Use #code instead.')
    code
  end

  def iso
    # Spree::Deprecation.warn('Use #code instead.')
    code
  end

  def states
    subregions
  end

  def numcode
    numeric_code
  end

  def iso3
    alpha_3_code
  end

  def iso_name
    name
  end

  def empty?
    false
  end
end
