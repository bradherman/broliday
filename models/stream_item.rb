class StreamItem
	include DataMapper::Resource
	include DataMapper::Validate

	property :id,		Serial
	property :message,	Text

	timestamps  :created_at , :updated_at
end