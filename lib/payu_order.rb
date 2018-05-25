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
        merchant_pos_id: OpenPayU::Configuration.merchant_pos_id,
        customer_ip: ip,
        ext_order_id: order.id,
        description: description,
        currency_code: order.currency,
        total_amount: (order.total * 100).to_i,
        order_url: order_url,
        notify_url: notify_url,
        continue_url: continue_url,
        products: products
    }
  end
end
