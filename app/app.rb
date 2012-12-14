require 'xml'
require 'aws/s3'

class Broliday < Padrino::Application
  register Padrino::Rendering
  register Padrino::Mailer
  register Padrino::Helpers

  enable :sessions

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

  get '/upload/:code' do |code|
    if @code = Code.get(code) and !@code.used
      erb :upload
    else
      redirect '/party-stream'
    end
  end

  post '/upload/:code' do |code|
    code = Code.get(code)
    uuid = SecureRandom.uuid
    upload("br/#{uuid}/#{params[:file][:filename]}", params[:file][:tempfile], "eazyparts")

    m = Message.create(
      :message => (params[:message] || code.message),
      :username => (code.name || "Web upload"),
      :image_url => "http://eazyparts.s3.amazonaws.com/br/#{uuid}/#{params[:file][:filename]}"
    )

    code.used = true
    code.save

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
      :message => "Thanks for partying! We'll send you alerts throughout the night with stuff to do."
    }

    send_message(params)
    true
  end

  def send_random(from)
      offsets = (0..rand(User.count-1)).to_a.sort{ rand() - 0.5 }[0..5]
      recipients = []

      offsets.each do |offset|
        recipients << User.first(:cell.not => from.to_s, :offset => offset)
      end
      
      recipients.each do |to|
        message = random_message(to.cell)

        params = {
          :client_id => MOGREET_CLIENT_ID, 
          :token => MOGREET_TOKEN, 
          :campaign_id => MOGREET_SMS_CAMPAIGN, 
          :to => to.cell, 
          :message => message
        }

        send_message(params)
      end

      params = {
        :client_id => MOGREET_CLIENT_ID, 
        :token => MOGREET_TOKEN, 
        :campaign_id => MOGREET_SMS_CAMPAIGN, 
        :to => from, 
        :message => "Texts went to #{recipients.map{|x|x.name}*", "}"
      }

      send_message(params)
  end

  def random_message(to)
    Activity.random(to)
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