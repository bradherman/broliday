require 'xml'

class Broliday < Padrino::Application
  register Padrino::Rendering
  register Padrino::Mailer
  register Padrino::Helpers

  enable :sessions

  MESSAGES = ["Get a picture of <target> doing a shot."]

  ##
  # You can manage errors like:
  #
  #   error 404 do
  #     render 'errors/404'
  #   end
  #
  #   error 505 do
  #     render 'errors/505'
  #   end
  #

  get '/' do
    erb :index
  end

  # post '/gift-a-shot' do
  #   if current_user.buy_shot
  #     begin
  #       order = params[:order]
  #       u = User.get(params[:user_id].to_i)

  #       message = "Happy brolidays! Some asshole just sent you an anonymous shot. Hit the bar to retrieve it. Feel free to gift some tonight. You have #{current_user.points.to_i} left :)"
        
  #       params = {
  #         :client_id => MOGREET_CLIENT_ID, 
  #         :token => MOGREET_TOKEN, 
  #         :campaign_id => MOGREET_SMS_CAMPAIGN, 
  #         :to => u.cell, 
  #         :message => message
  #       }
        
  #       # also need to send order to bartender

  #       logger.info Mechanize.new.post(MOGREET_URI, params).body
  #       StreamItem.create(:message => "Someone just sent #{u.name} a #{order}!  Let's get weird!")
        
  #       200
  #     rescue
  #       500
  #     end
  #   else
  #     400
  #   end
  # end

  post '/message' do
    doc = XML::Parser.string(request.body.read).parse

    logger.info doc

    campaign = doc.find("campaign_id").first.content
    number = doc.find("msisdn").first.content
    carrier = doc.find("carrier").first.content
    message = (doc.find("message").first.content.gsub(/(^broliday\s?)|(^br\s?)/i, '').gsub("\n", "") rescue nil)
    subject = (doc.find("subject").first.content rescue nil)

    user = User.first(:cell => number)

    (create_user(doc) and return) unless user

    if message.scan(/bradmin/i).present?
      send_random(number) and return
    end

    logger.info "Creating message"

    m = Message.create(
      :campaign_id => campaign,
      :number => number,
      :carrier => carrier,
      :message => message,
      :subject => subject,
      :username => user.name
    )

    m.image_url = doc.find("//image").first.content rescue nil

    m.save
  end

  get '/party-stream' do
    @messages = Message.all(:order => :created_at.desc)
    erb :party_stream
  end

  get '/items' do
    @messages = Message.all(:order => :created_at.desc)
    render :json => @messages
  end

  def create_user(doc)
    logger.info "Creating new user"

    u=User.create(
      :cell => doc.find("msisdn").first.content,
      :name => (doc.find("message").first.content.gsub(/(broliday\s?)|(br\s?)/i, '') rescue "").titleize
    )

    params = {
      :client_id => MOGREET_CLIENT_ID, 
      :token => MOGREET_TOKEN, 
      :campaign_id => MOGREET_SMS_CAMPAIGN, 
      :to => u.cell, 
      :message => "Thanks for partyin, bro. We'll send you alerts throughout the night with stuff to do. You can also text BR plus a pic or message to get it displayed on screen. #Sorryforparty"
    }

    logger.info params

    Mechanize.new.post(MOGREET_URI, params).body
  end

  def send_random(number)
    logger.info "Sending a random text"

    offset = rand(User.count-1)

    user = User.first(:cell.not => number, :offset => offset)

    if user
      message = random_message(user)
      params = {
        :client_id => MOGREET_CLIENT_ID, 
        :token => MOGREET_TOKEN, 
        :campaign_id => MOGREET_SMS_CAMPAIGN, 
        :to => user.cell, 
        :message => message
      }

      Mechanize.new.post(MOGREET_URI, params).body

      params = {
        :client_id => MOGREET_CLIENT_ID, 
        :token => MOGREET_TOKEN, 
        :campaign_id => MOGREET_SMS_CAMPAIGN, 
        :to => number, 
        :message => "We just sent a random text to #{user.name}"
      }

      Mechanize.new.post(MOGREET_URI, params).body
    end
  end

  def random_message(user)
    logger.info "Sending random message"
    offset = rand(User.count-1)
    target = User.first(:cell.not => user.cell, :offset => offset)
    MESSAGES.sample.gsub(/<target>/, target.name)
  end
end