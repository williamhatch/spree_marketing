desc 'generate all the available smart lists'
namespace :spree_marketing do
  namespace :smart_list do
    task generate_all: :environment do |_t, _args|
      Spree::Marketing::List.generate_all
    end

    task generate_abandoned_cart: :environment do |_t, _args|
      Spree::Marketing::List.generate(Spree::Marketing::List::AbandonedCart)
    end
  end
end
