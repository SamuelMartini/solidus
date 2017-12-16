Carmen::Region.class_eval do
  def to_hash
    { type: type, code: code, name: name, subregions: subregions, parent: parent.code }
  end
end

Carmen::Country.class_eval do
  def iso_code
    Spree::Deprecation.warn('Use #code instead.')
    code
  end

  def iso
    Spree::Deprecation.warn('Use #code instead.')
    code
  end
end
