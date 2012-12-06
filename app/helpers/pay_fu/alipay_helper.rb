require 'digest/md5'

module PayFu
  module AlipayHelper
    def redirect_to_alipay_gateway(options={})
      encoded_query_string = sign_params!(query_params(options)).map {|key, value| "#{key}=#{CGI.escape(value)}" }.join("&")
      redirect_to "https://www.alipay.com/cooperate/gateway.do?" + encoded_query_string
    end

    private
    def query_params(options)
      query_params = {
        :partner => ActiveMerchant::Billing::Integrations::Alipay::ACCOUNT,
        :out_trade_no => options[:out_trade_no],
        :price => options[:amount],
        :quantity => '1',
        :seller_email => ActiveMerchant::Billing::Integrations::Alipay::EMAIL,
        :notify_url => options[:notify_url],
        :body => options[:body],
        :"_input_charset" => 'utf-8',
        :service => ActiveMerchant::Billing::Integrations::Alipay::Helper::CREATE_PARTNER_TRADE_BY_BUYER,
        :payment_type => "1",
        :subject => options[:subject],
        :logistics_type => options[:logistics_type],
        :logistics_fee => options[:logistics_fee],
        :logistics_payment => options[:logistics_payment],
        :receive_name => options[:recevie_name],
        :receive_address => option[:recevie_address]
      }
      query_params[:body] = options[:body] if options[:body]
      query_params[:return_url] = options[:return_url] if options[:return_url]
      Hash[query_params.sort]
    end

    def sign_params!(params)
      raw_query_string = params.map {|key, value| "#{key}=#{CGI.unescape(value)}" }.join("&")
      sign = Digest::MD5.hexdigest(raw_query_string + ActiveMerchant::Billing::Integrations::Alipay::KEY)
      params[:sign] = sign
      params[:sign_type] = 'MD5'
      params
    end
  end
end
