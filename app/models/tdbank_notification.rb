# The +TdbankNotification+ class handles notifications sent by Tdbank to your servers.
#
# Because notifications contain important payment status information, you should store
# these notifications in your database. For this reason, +TdbankNotification+ inherits
# from +ActiveRecord::Base+, and a migration is included to simply create a suitable table
# to store the notifications in.
#
# Tdbank can either send notifications to you via HTTP POST requests, or SOAP requests.
# Because SOAP is not really well supported in Rails and setting up a SOAP server is
# not trivial, only handling HTTP POST notifications is currently supported.
#
# @example
#    @notification = TdbankNotification.log(request)
#    if @notification.successful_authorisation?
#      @invoice = Invoice.find(@notification.merchant_reference)
#      @invoice.set_paid!
#    end
class TdbankNotification < ActiveRecord::Base

  # A notification should always include an event_code
  validates_presence_of :event_code

  # A notification should always include a psp_reference
  validates_presence_of :psp_reference

  # A notification should be unique using the composed key of
  # [:psp_reference, :event_code, :success]
  validates_uniqueness_of :success, :scope => [:psp_reference, :event_code]

  # Make sure we don't end up with an original_reference with an empty string
  before_validation { |notification| notification.original_reference = nil if notification.original_reference.blank? }

  # Logs an incoming notification into the database.
  #
  # @param [Hash] params The notification parameters that should be stored in the database.
  # @return [Tdbank::Notification] The initiated and persisted notification instance.
  # @raise This method will raise an exception if the notification cannot be stored.
  # @see Tdbank::Notification::HttpPost.log
  def self.log(params)
    converted_params = {}

    # Assign explicit each attribute from CamelCase notation to notification
    # For example, merchantReference will be converted to merchant_reference
    self.new.tap do |notification|
      params.each do |key, value|
        setter = "#{key.to_s.underscore}="
        notification.send(setter, value) if notification.respond_to?(setter)
      end
      notification.save!
    end
  end

  # Returns true if this notification is an AUTHORISATION notification
  # @return [true, false] true iff event_code == 'AUTHORISATION'
  # @see Tdbank.notification#successful_authorisation?
  def authorisation?
    event_code == 'AUTHORISATION'
  end

  def capture?
    event_code == 'CAPTURE'
  end

  alias_method :authorization?, :authorisation?

  # Returns true if this notification is an AUTHORISATION notification and
  # the success status indicates that the authorization was successfull.
  # @return [true, false] true iff  the notification is an authorization
  #   and the authorization was successful according to the success field.
  def successful_authorisation?
    authorisation? && success?
  end

  alias_method :successful_authorization?, :successful_authorisation?

  # Invalidate payments that doesnt receive a successful notification
  def handle!
    if (authorisation? || capture?) && !success?
      payment = Spree::Payment.find_by(response_code: psp_reference)
      if payment && !payment.failed? && !payment.invalid?
        payment.invalidate!
      end
    end
  end
end
