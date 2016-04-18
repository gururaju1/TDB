module Spree
  module Tdbank
    module CheckoutRescue
      extend ActiveSupport::Concern

      included do
        rescue_from Tdbank::Enrolled3DError, :with => :rescue_from_tdbank_3d_enrolled

        def rescue_from_tdbank_3d_enrolled(exception)
          session[:tdbank_gateway_id] = exception.gateway.id
          session[:tdbank_gateway_name] = exception.gateway.class.name

          @tdbank_3d_response = exception
          render 'spree/checkout/tdbank_3d_form'
        end
      end
    end
  end
end
