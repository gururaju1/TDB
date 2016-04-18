# Spree Tdbank Integration

Easily integrates Tdbank payments into a Spree store. It works as a wrapper
of the [awesome tdbank](https://github.com/gururaju1/TDB/) gem which contains
all basic API calls for Tdbank payment services.

## Installation

Add this line to your application's Gemfile:

    gem 'spree-tdbank', github: '/gururaju1/TDB'

And then execute:

    $ bundle

Copy the tdbank notification migration. You'll need it to save all notifications
responses.

    $ rake railties:install:migrations

## Usage

To integrate with Tdbank Payments you'll need to request API credentials by
signing up at Tdbank website https://www.tdbank.com/.

This extension provides three Payment Methods. In order to use TdbankPayment and
TdbankPaymentEncrypted method you'll need to make sure your account is enabled to
use Tdbank API Payments, needed to authorize payments via their SOAP API.

The other payment method, TdbankHPP, allows your store to authorize payments
using Tdbank Hosted Payments Page solution. In this case the customer will enter
cc in Tdbank website and be redirected back to the store after the payment.

For the TdbankHPP method you'll need to create a skin in your merchant dashboard
and add the skin_code and shared_secret to the payment method on Spree backend UI.

All subsequent calls, e.g. capture, are done via Tdbank SOAP API by both payment
methods.

Make sure that you config your notification settings in Tdbank Merchant dashboard.
You need to set URL, choose HTTP POST and set a username and password for
authentication. The username and password need to be set as environment variables
, TDBANK_NOTIFY_USER and TDBANK_NOTIFY_PASSWD, so that notifications can successfully
persist on your application database.


## Testing

The extension contains some specs that will reach out tdbank API the first time
you run them. Those are marked with the external tag and they need credentials
so you'll have to set up a config/credentials.yml file. Theres's a helper
`test_crendentials` available on the specs to call each key on that yaml file.
Also it uses VCR to record the requests so you'll need to delete those files
to do a new request.

Required to run specs: create a dummy Rails app as testing environment:

```ruby
bundle exec rake test_app
```

You can run external specs like this:

```ruby
bundle exec rspec spec --tag external
```



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
