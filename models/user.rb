class User
	include DataMapper::Resource
	include DataMapper::Validate

	property :id,		Serial
	property :name,		String	,	:required => true
	property :cell,		String	,	:required => true	,	:unique => true

	property :points,	Integer	,	:default => 5

	def buy_shot
		if self.points > 0
			self.points -= 1
			self.save
			true
		else
			false
		end
	end

	def take_shot
		self.points += 1
		self.save
	end

	def send_message(message)
		params = {
	        :client_id => MOGREET_CLIENT_ID, 
	        :token => MOGREET_TOKEN, 
	        :campaign_id => MOGREET_SMS_CAMPAIGN, 
	        :to => self.cell, 
	        :message => message
	    }
		Mechanize.new.post(MOGREET_URI, params).body
	end
end
