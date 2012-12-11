class Message
	include DataMapper::Resource
	include DataMapper::Validate

	property :id,		Serial
	property :body,		Text
end