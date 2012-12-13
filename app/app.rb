require 'xml'
require 'aws/s3'

class Broliday < Padrino::Application
  register Padrino::Rendering
  register Padrino::Mailer
  register Padrino::Helpers

  enable :sessions

  MESSAGES = ["Get a picture of <target> doing a shot."]
  INSTRUCTIONS = " Go to http://broliday.herokuapp.com/upload to send to the stream."

  #### ROUTES ####

  get '/' do
    erb :index
  end

  post '/message' do
    doc = XML::Parser.string(request.body.read).parse

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

  get '/upload' do
    erb :upload
  end

  post '/upload' do
    upload("br/#{params[:file][:filename]}", params[:file][:tempfile], "eazyparts")

    m = Message.create(
      :message => (params[:message] || nil),
      :username => "Web Upload",
      :image_url => "http://eazyparts.s3.amazonaws.com/br/#{params[:file][:filename]}"
    )

    redirect '/party-stream'
  end

  #### METHODS ####

  def create_user(doc)
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

    send_message(params)
  end

  def send_random(number)
    offset = rand(User.count-1)
    u = User.first(:cell.not => number.to_s, :offset => offset)

    if u
      message = random_message(u)
      params = {
        :client_id => MOGREET_CLIENT_ID, 
        :token => MOGREET_TOKEN, 
        :campaign_id => MOGREET_SMS_CAMPAIGN, 
        :to => u.cell, 
        :message => message
      }

      send_message(params)

      params = {
        :client_id => MOGREET_CLIENT_ID, 
        :token => MOGREET_TOKEN, 
        :campaign_id => MOGREET_SMS_CAMPAIGN, 
        :to => number, 
        :message => "We just sent a random text to #{u.name}: #{u.cell}: #{message}"
      }

      send_message(params)
    end
  end

  def random_message(u)
    logger.info "Sending random message"
    offset = rand(User.count-1)
    target = User.first(:cell.not => u.cell, :offset => offset)
    MESSAGES.sample.gsub(/<target>/, target.name).concat(INSTRUCTIONS)
  end

  def send_message(params)
    Mechanize.new.post(MOGREET_URI, params).body
  end

  def upload(name, tmpfile, bucket)
    while blk = tmpfile.read(65536)
      AWS::S3::Base.establish_connection!(
      :access_key_id     => S3_ACCESS_KEY,
      :secret_access_key => S3_SECRET)
      AWS::S3::S3Object.store(name,open(tmpfile),bucket,:access => :public_read)
    end
    true
  end
end