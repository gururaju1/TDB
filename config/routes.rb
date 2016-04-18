Spree::Core::Engine.routes.draw do
  get "checkout/payment/tdbank", to: "tdbank_redirect#confirm", as: :tdbank_confirmation
  post "tdbank/notify", to: "tdbank_notifications#notify"
  post "tdbank/authorise3d", to: "tdbank_redirect#authorise3d", as: :tdbank_authorise3d
end
