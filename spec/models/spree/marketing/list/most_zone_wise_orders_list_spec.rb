require "spec_helper"

describe Spree::Marketing::MostZoneWiseOrdersList, type: :model do

  let!(:second_user) { create(:user) }
  let(:state) { create(:state) }
  let(:entity_key) { state.id }
  let(:entity_name) { state.name.downcase.gsub(" ", "_") }
  let!(:user_with_completed_orders_with_shipping_address_having_given_state) { create(:user_with_completed_orders, :with_given_shipping_state, state: state, orders_count: 6) }

  it_behaves_like "acts_as_multilist", Spree::Marketing::MostZoneWiseOrdersList

  describe "Constants" do
    it "ENTITY_KEY equals to the entity_key used for list" do
      expect(Spree::Marketing::MostZoneWiseOrdersList::ENTITY_KEY).to eq 'state_id'
    end
    it "TIME_FRAME equals to time frame used in filtering of users for list" do
      expect(Spree::Marketing::MostZoneWiseOrdersList::TIME_FRAME).to eq 1.month
    end
    it "MOST_ZONE_WISE_ORDERS_COUNT equals to count of zones to be used as data for list" do
      expect(Spree::Marketing::MostZoneWiseOrdersList::MOST_ZONE_WISE_ORDERS_COUNT).to eq 5
    end
  end

  describe "methods" do
    describe ".state_name" do
      it "returns the name of state according to the state_id given" do
        expect(Spree::Marketing::MostZoneWiseOrdersList.send :state_name, state.id).to eq "alabama"
      end
    end

    describe ".name_text" do
      it "returns the name_text of list to be used as name of list" do
        expect(Spree::Marketing::MostZoneWiseOrdersList.send :name_text, state.id).to eq "most_zone_wise_orders_list_alabama"
      end
    end

    describe ".data" do
      context "method flow" do
        it "includes the entity state id" do
          expect(Spree::Marketing::MostZoneWiseOrdersList.send :data).to include state.id
        end
      end

      context "limit to MOST_ZONE_WISE_ORDERS_COUNT" do
        let(:second_state) { create(:state, name: "State 2") }
        let(:third_state) { create(:state, name: "State 3") }
        let(:fourth_state) { create(:state, name: "State 4") }
        let(:fifth_state) { create(:state, name: "State 5") }
        let(:sixth_state) { create(:state, name: "State 6") }
        let!(:orders_in_second_state) { create_list(:order_with_given_shipping_state, 6, state: second_state) }
        let!(:orders_in_third_state) { create_list(:order_with_given_shipping_state, 6, state: third_state) }
        let!(:orders_in_fourth_state) { create_list(:order_with_given_shipping_state, 6, state: fourth_state) }
        let!(:orders_in_fifth_state) { create_list(:order_with_given_shipping_state, 6, state: fifth_state) }
        let!(:orders_in_sixth_state) { create_list(:order_with_given_shipping_state, 1, state: sixth_state) }

        it "includes top 5 states where most orders are placed" do
          expect(Spree::Marketing::MostZoneWiseOrdersList.send :data).to include *[state.id, second_state.id, third_state.id, fourth_state.id, fifth_state.id]
        end
        it "doesn't include states which is not in top 5 states where most orders are placed" do
          expect(Spree::Marketing::MostZoneWiseOrdersList.send :data).to_not include sixth_state.id
        end
      end
    end

    describe "#user_ids" do
      context "with orders not having selected state" do
        let(:registered_user) { create(:user) }
        let(:other_state) { create(:state, name: "Other state") }
        let!(:orders_in_other_state) { create_list(:order_with_given_shipping_state, 6, state: other_state, user_id: registered_user.id) }

        it "includes users who has placed order in the entity state" do
          expect(Spree::Marketing::MostZoneWiseOrdersList.new(state_id: state.id).user_ids).to include user_with_completed_orders_with_shipping_address_having_given_state.id
        end
        it "doesn't include users who has placed no orders in the entity state" do
          expect(Spree::Marketing::MostZoneWiseOrdersList.new(state_id: state.id).user_ids).to_not include registered_user.id
        end
      end

      context "when user is not registered" do
        let(:guest_user_email) { "spree@example.com" }
        let!(:guest_user_order) { create(:order_with_given_shipping_state, user_id: nil, email: guest_user_email, state: state) }

        it "doesn't include guest users who have placed orders in the entity state" do
          expect(Spree::Marketing::MostZoneWiseOrdersList.new(state_id: state.id).send :emails).to_not include guest_user_email
        end
      end

      context "when orders are completed before TIME_FRAME" do
        let(:timestamp) { Time.current - 2.months }
        let(:registered_user) { create(:user) }
        let!(:old_completed_order) { create(:order_with_given_shipping_state, :with_custom_completed_at, user_id: registered_user.id, state: state, completed_at: timestamp) }

        it "doesn't include users who have placed order before the time frame in the entity state" do
          expect(Spree::Marketing::MostZoneWiseOrdersList.new(state_id: state.id).send :user_ids).to_not include registered_user.id
        end
      end
    end
  end

end
