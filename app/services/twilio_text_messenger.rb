class TwilioTextMessenger
  def initialize(message, number)
    @message = message
    @number = number
  end

  def send
    client = Twilio::REST::Client.new(
      Rails.application.credentials.twilio[:account_sid],
      Rails.application.credentials.twilio[:auth_token]
    )
    
    client.messages.create({
      from: Rails.application.credentials.twilio[:phone_number],
      to: number,
      body: message
    })
  end

  private
  
  attr_reader :message, :number
end