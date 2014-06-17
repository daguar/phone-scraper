class OutboundCaller
  attr_reader :client

  def initialize
    if env_vars_present?
      @client = Twilio::REST::Client.new(ENV['TWILIO_SID'], ENV['TWILIO_AUTH'])
    end
  end

  def call(outbound_phone_number, twiml_url)
    client.account.calls.create(
      from: ENV['TWILIO_NUMBER'],
      to: outbound_phone_number,
      url: twiml_url,
      method: 'GET',
    )
  end

  private
  def env_vars_present?
    missing_vars = ['TWILIO_SID', 'TWILIO_AUTH', 'TWILIO_NUMBER'].select do |var|
      ENV.has_key?(var) == false
    end
    if missing_vars.length > 0
      raise StandardError, "Missing environment variable(s): #{missing_vars}"
    else
      return true
    end
  end
end
