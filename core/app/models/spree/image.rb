module Spree
  class Image < Asset
    Spree::Config.image_attachment_class.has_attachment(
      self,
      :attachment,
      options: {
        styles: { mini: '48x48>', small: '100x100>', product: '240x240>', large: '600x600>' },
        default_style: :product,
        default_url: 'noimage/:style.png',
        url: '/spree/products/:id/:style/:basename.:extension',
        path: ':rails_root/public/spree/products/:id/:style/:basename.:extension',
        convert_options: { all: '-strip -auto-orient -colorspace sRGB' }
      },
      validators: {
        presence: true, content_type: %w(image/jpg image/jpeg image/png image/gif)
      }
    )
  end
end
