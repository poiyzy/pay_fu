module PayFu
  class Transaction < ActiveRecord::Base
    belongs_to :user, class_name: User
    attr_accessible :transaction_id, :transaction_type, :payment_status, :payment_date, :gross, :raw_post, :type, :user_id

    after_create :update_product_to_user
    after_save :update_product_to_user

    def update_product_to_user
      if self.payment_status == "TRADE_FINISHED"
        self.user.payment.created_at = self.updated_at
        self.user.payment.save
      end
    end
  end
end

