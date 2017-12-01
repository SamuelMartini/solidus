module Spree
  class Price < Spree::Base
    acts_as_paranoid

    MAXIMUM_AMOUNT = BigDecimal('99_999_999.99')

    belongs_to :variant, -> { with_deleted }, class_name: 'Spree::Variant', touch: true
    # belongs_to :country, class_name: "Spree::Country", foreign_key: "country_iso", primary_key: "iso"
    # Should I continue to let this thing be country?
    def country
      Carmen::Country.coded(country_iso)
    end

    delegate :product, to: :variant
    delegate :tax_rates, to: :variant

    validate :check_price
    validates :amount, allow_nil: true, numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: MAXIMUM_AMOUNT
    }
    validates :currency, inclusion: { in: ::Money::Currency.all.map(&:iso_code), message: :invalid_code }
    # validates :country, presence: true, unless: -> { for_any_country? }
    validates :country_iso, inclusion: { in: Carmen::Country.all.map(&:alpha_2_code) }, unless: -> { for_any_country? }

    scope :currently_valid, -> { order("country_iso IS NULL, updated_at DESC, id DESC") }
    scope :for_master, -> { joins(:variant).where(spree_variants: { is_master: true }) }
    scope :for_variant, -> { joins(:variant).where(spree_variants: { is_master: false }) }
    scope :for_any_country, -> { where(country_iso: nil) }
    scope :with_default_attributes, -> { where(Spree::Config.default_pricing_options.desired_attributes) }

    extend DisplayMoney
    money_methods :amount, :price
    alias_method :money, :display_amount

    self.whitelisted_ransackable_attributes = %w( amount variant_id currency country_iso )

    # An alias for #amount
    def price
      amount
    end

    # Sets this price's amount to a new value, parsing it if the new value is
    # a string.
    #
    # @param price [String, #to_d] a new amount
    def price=(price)
      self[:amount] = Spree::LocalizedNumber.parse(price)
    end

    def net_amount
      amount / (1 + sum_of_vat_amounts)
    end

    def for_any_country?
      country_iso.nil?
    end

    def display_country
      if country_iso
        "#{country_iso} (#{country.name})"
      else
        I18n.t(:any_country, scope: [:spree, :admin, :prices])
      end
    end

    def country_iso=(country_iso)
      self[:country_iso] = country_iso.presence
    end

    private

    def sum_of_vat_amounts
      return 0 unless variant.tax_category
      tax_rates.included_in_price.for_country(country).sum(:amount)
    end

    def check_price
      self.currency ||= Spree::Config[:currency]
    end

    def pricing_options
      Spree::Config.pricing_options_class.from_price(self)
    end
  end
end
