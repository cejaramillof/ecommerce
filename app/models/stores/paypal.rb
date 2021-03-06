#Module Stores
#  class Paypal
#  end
#end
class Stores::Paypal
  include PayPal::SDK::REST
  #attr_reader :payment    ->   paypal.payment
  #attr_writer :payment    ->   paypal.payment = "Hola "
  attr_accessor :payment #tiene los dos anteriores (accessor vs variable de clase)
  attr_accessor :total, :items
  attr_accessor :return_url, :cancel_url
  
  def initialize(total,items,options={})
    self.total = total
    self.items = items
    options.each { |clave,valor| instance_variable_set("@#{clave}",valor) }
    #self.return_url = options[:return_url]
    #self.cancel_url = options[:cancel_url]
  end
  
  def process_payment
    # Build Payment object
    self.payment = Payment.new(payment_options)
    self.payment
  end
  
  def payment_options
    {
      intent: "sale",
      payer: {
        payment_method: "paypal"
      },
      transactions: [{
        item_list: {
          items: self.items
        },
        amount: {
          total: (self.total),
          currency: "USD"
        },
        description: "Compra de tus productos en nuestra plataforma."
      }],
      redirect_urls: {
        return_url: @return_url,
        cancel_url: @cancel_url
      }
    }
  end
  
  def self.get_email(payment_id)
    payment = Payment.find(payment_id)
    payment.payer.payer_info.email
  end
  
  def self.checkout(payer_id,payment_id,&block)
    payment = Payment.find(payment_id)
    if payment.execute(payer_id: payer_id)
      yield if block_given?
    end
  end
end