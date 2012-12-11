class Message
	include DataMapper::Resource
	include DataMapper::Validate

	property :id,			Serial
	property :campaign_id,	Integer
	property :number,		String
	property :carrier,  	String
	property :message, 		Text
	property :image_url,	String
	property :subject,		Text

	property :created_at,	DateTime, :default => lambda{Time.now}
end