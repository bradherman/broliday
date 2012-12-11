require 'xml'

class Broliday < Padrino::Application
  register Padrino::Rendering
  register Padrino::Mailer
  register Padrino::Helpers

  enable :sessions

  # Client ID: 1320
  # Token: 61d5ae55854a90d390cf8adcd49d8a0a
  # Campaign IDs: 28453(sms), 28498(multimedia)
  # https://api.mogreet.com/moms/transaction.send?client_id=1320&token=61d5ae55854a90d390cf8adcd49d8a0a&to=3173319718&message=test&campaign_id=28453

  ##
  # Caching support
  #
  # register Padrino::Cache
  # enable :caching
  #
  # You can customize caching store engines:
  #
  #   set :cache, Padrino::Cache::Store::Memcache.new(::Memcached.new('127.0.0.1:11211', :exception_retry_limit => 1))
  #   set :cache, Padrino::Cache::Store::Memcache.new(::Dalli::Client.new('127.0.0.1:11211', :exception_retry_limit => 1))
  #   set :cache, Padrino::Cache::Store::Redis.new(::Redis.new(:host => '127.0.0.1', :port => 6379, :db => 0))
  #   set :cache, Padrino::Cache::Store::Memory.new(50)
  #   set :cache, Padrino::Cache::Store::File.new(Padrino.root('tmp', app_name.to_s, 'cache')) # default choice
  #

  ##
  # Application configuration options
  #
  # set :raise_errors, true       # Raise exceptions (will stop application) (default for test)
  # set :dump_errors, true        # Exception backtraces are written to STDERR (default for production/development)
  # set :show_exceptions, true    # Shows a stack trace in browser (default for development)
  # set :logging, true            # Logging in STDOUT for development and file for production (default only for development)
  # set :public_folder, "foo/bar" # Location for static assets (default root/public)
  # set :reload, false            # Reload application files (default in development)
  # set :default_builder, "foo"   # Set a custom form builder (default 'StandardFormBuilder')
  # set :locale_path, "bar"       # Set path for I18n translations (default your_app/locales)
  # disable :sessions             # Disabled sessions by default (enable if needed)
  # disable :flash                # Disables sinatra-flash (enabled by default if Sinatra::Flash is defined)
  # layout  :my_layout            # Layout can be in views/layouts/foo.ext or views/foo.ext (default :application)
  #

  ##
  # You can configure for a specified environment like:
  #
  #   configure :development do
  #     set :foo, :bar
  #     disable :asset_stamp # no asset timestamping for dev
  #   end
  #

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

  # before do
  #   redirect '/login' unless current_user or request.path == '/login'
  # end

  get '/' do
    erb :index
  end

  # get '/login' do
  #   erb :login
  # end

  # post '/login' do
  #   u = User.new(params[:user])
  #   if u.save
  #     session[:user] = u.cell
  #     redirect '/'
  #   else
  #     redirect '/login'
  #   end
  # end

  # get '/gift-a-shot' do
  #   erb :gift_a_shot
  # end

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

  #       puts Mechanize.new.post(MOGREET_URI, params).body
  #       StreamItem.create(:message => "Someone just sent #{u.name} a #{order}!  Let's get weird!")
        
  #       200
  #     rescue
  #       500
  #     end
  #   else
  #     400
  #   end
  # end

  # get '/leaderboard' do
  # end

  post '/message' do
    doc = XML::Parser.string(request.body.read).parse

    user = User.first(:cell => doc.find("msisdn").first.content)

    unless user
      create_user(doc)
      return
    end

    m = Message.create(
      :campaign_id => doc.find("campaign_id").first.content,
      :number => doc.find("msisdn").first.content,
      :carrier => doc.find("carrier").first.content,
      :message => (doc.find("message").first.content.gsub(/broliday\s/i, '') rescue nil),
      :subject => (doc.find("subject").first.content rescue nil)
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
    u=User.create(
      :cell => doc.find("msisdn").first.content,
      :name => doc.find("message").first.content
    )

    params = {
      :client_id => MOGREET_CLIENT_ID, 
      :token => MOGREET_TOKEN, 
      :campaign_id => MOGREET_SMS_CAMPAIGN, 
      :to => u.cell, 
      :message => "Thanks for signing up.  Be sure to include the keyword BROLIDAY in all of your messages to 343434!"
    }

    puts Mechanize.new.post(MOGREET_URI, params).body

    return
  end
end