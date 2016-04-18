module Spree
  module Tdbank
    class Engine < ::Rails::Engine
      engine_name "spree-tdbank"

      isolate_namespace Spree::Tdbank

      initializer "spree.spree-tdbank.payment_methods", :after => "spree.register.payment_methods" do |app|
        app.config.spree.payment_methods << Gateway::TdbankPayment
        app.config.spree.payment_methods << Gateway::TdbankHPP
        app.config.spree.payment_methods << Gateway::TdbankPaymentEncrypted
      end

      initializer "spree-tdbank.assets.precompile", :group => :all do |app|
        app.config.assets.precompile += %w[
          tdbank.encrypt.js
        ]
      end
    end
  end
end
