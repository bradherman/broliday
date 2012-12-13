class Code
	include DataMapper::Resource
	include DataMapper::Validate

	property :id,		Serial
	property :used,		Boolean,	:default	=>	false
	property :message,	Text
	property :name,		Text
end