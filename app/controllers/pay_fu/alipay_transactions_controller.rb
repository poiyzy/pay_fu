require 'digest/md5'
require 'open-uri'

module PayFu
  class AlipayTransactionsController < ApplicationController
    include ActiveMerchant::Billing::Integrations

    def notify
      notify = Alipay::Notification.new(request.raw_post)
      if notify.acknowledge
        if transaction = PayFu::AlipayTransaction.find_by_transaction_id(notify.trade_no)
          transaction.update_attributes(transaction_attributes(notify))
        else
          PayFu::AlipayTransaction.create(transaction_attributes(notify))
        end

        send_goods(trade_no: notify.trade_no, amount: notify.price, invoice_no: notify.out_trade_no) if notify.trade_status == "WAIT_SELLER_SEND_GOODS"

      end
      render :nothing => true
    end

    def transaction_attributes(notify)
      @transaction_attributes ||= {
        :transaction_id => notify.trade_no,
        :transaction_type => notify.payment_type,
        :payment_status => notify.trade_status,
        :payment_date => notify.notify_time,
        :gross => notify.total_fee,
        :raw_post => notify.raw,
        :user_id => notify.receive_mobile.to_i
      }
    end

    def send_goods(options={})
      encoded_query_string = sign_params!(query_params(options)).map {|key, value| "#{key}=#{CGI.escape(value)}" }.join("&")
      open("https://mapi.alipay.com/gateway.do?" + encoded_query_string)
    end

    private
    def query_params(options)
      query_params = {
        :partner => ActiveMerchant::Billing::Integrations::Alipay::ACCOUNT,
        :trade_no => options[:trade_no],
        :price => options[:amount],
        :"_input_charset" => 'utf-8',
        :service => "send_goods_confirm_by_platform",
        :logistics_name => "zirannanren",
        :invoice_no => options[:invoice_no],
        :transport_type => "POST"
      }
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
