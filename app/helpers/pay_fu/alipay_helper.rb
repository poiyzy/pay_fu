require 'digest/md5'

module PayFu
  module AlipayHelper
    def redirect_to_alipay_gateway(options={})
      query_string = query_params(options).sort.map { |key, value| "#{key}=#{CGI.unescape(value)}" }.join("&")
      sign = Digest::MD5.hexdigest(query_string + ActiveMerchant::Billing::Integrations::Alipay::KEY)
      query_string += "&sign=#{sign}&sign_type=MD5"

      redirect_to "https://www.alipay.com/cooperate/gateway.do?" + query_string
    end

    private
    def query_params(options)
      query_params = {
        :partner => ActiveMerchant::Billing::Integrations::Alipay::ACCOUNT,
        :out_trade_no => options[:out_trade_no],
        :total_fee => options[:amount],
        :seller_email => ActiveMerchant::Billing::Integrations::Alipay::EMAIL,
        :notify_url => options[:notify_url],
        :"_input_charset" => 'utf-8',
        :service => ActiveMerchant::Billing::Integrations::Alipay::Helper::CREATE_DIRECT_PAY_BY_USER,
        :payment_type => "1",
        :subject => options[:subject]
      }
      query_params[:body] = options[:body] if options[:body]
      query_params
    end
  end
end
