class PayuOrder
  include Rails.application.routes.url_helpers

  def self.params(order, ip, order_url, notify_url, continue_url)
    products = order.line_items.map do |li|
      {
        name: li.product.name,
        unit_price: (li.price * 100).to_i,
        quantity: li.quantity
      }
    end
   
    product_name = products.collect{|c| c[:name]}.join(",")
    
    Rails.logger.info "Order #{order.id}"
    hash = Digest::SHA512.hexdigest("gtKFFx|#{order.number}|#{(order.total * 100).to_i}|#{product_name}|#{order.bill_address.firstname}|#{order.email}|||||||||||eCwWELxi")
    
    description = I18n.t('order_description',
      name: "HandMade")
    description = I18n.transliterate(description)

    {
      key: OpenPayU::Configuration.merchant_pos_id,
    #  customer_ip: ip,
      txnid: "#{order.number}",
      amount: (order.total * 100).to_i,
    #  order_url: order_url,
      surl: notify_url,
      furl: continue_url,
      hash: hash,
      email: order.email,
      phone: order.bill_address.phone,
      productinfo: product_name,
      firstname: order.bill_address.firstname,
      salt: "eCwWELxi"
        # delivery: {
        #   street: order.shipping_address.address1,
        #   postal_code: order.shipping_address.zipcode,
        #   city: order.shipping_address.city,
        #   country_code: order.bill_address.country.iso
        # }
    }
  end
end
