module Spree
  module Marketing
    class List
      class AbandonedCart < Spree::Marketing::List
        # Constants
        NAME_TEXT = 'Abandoned Cart'
        AVAILABLE_REPORTS = [:purchases_by].freeze

        def user_ids
        end

        private

          def users_data
            Spree::Order.incomplete
                        .where('spree_orders.updated_at >= ?', Time.now.in_time_zone - 24.hours)
                        .where('spree_orders.user_id IS NULL')
                        .where('spree_orders.email IS NOT NULL')
                        .where.not(item_count: 0)
                        .distinct
                        .pluck(:email, :guest_token)
                        .to_h
          end
      end
    end
  end
end
