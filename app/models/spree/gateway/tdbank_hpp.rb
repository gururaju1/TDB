module Spree
  # Gateway for Tdbank Hosted Payment Pages solution
  class Gateway::TdbankHPP < Gateway
    include TdbankCommon

    preference :skin_code, :string
    preference :shared_secret, :string

    def source_required?
      false
    end

    def auto_capture?
      false
    end

    # Spree usually grabs these from a Credit Card object but when using
    # Tdbank Hosted Payment Pages where we wouldn't keep # the credit card object
    # as that entered outside of the store forms
    def actions
      %w{capture void}
    end

    # Indicates whether its possible to void the payment.
    def can_void?(payment)
      !payment.void?
    end

    # Indicates whether its possible to capture the payment
    def can_capture?(payment)
      payment.pending? || payment.checkout?
    end

    def method_type
      "Tdbank"
    end

    def shared_secret
      ENV['TDBANK_SHARED_SECRET'] || preferred_shared_secret
    end

    def skin_code
      ENV['TDBANK_SKIN_CODE'] || preferred_skin_code
    end

    # According to Spree Processing class API the response object should respond
    # to an authorization method which return value should be assigned to payment
    # response_code
    def void(response_code, gateway_options = {})
      response = provider.cancel_payment(response_code)

      if response.success?
        def response.authorization; psp_reference; end
      else
        # TODO confirm the error response will always have these two methods
        def response.to_s
          "#{result_code} - #{refusal_reason}"
        end
      end
      response
    end

  end
end
