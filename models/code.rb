class Code
	include DataMapper::Resource
	include DataMapper::Validate

	property :id,		Serial
	property :value,	String	,	:length => 6,	:required => true,	:unique => true

	def self.include?(code)
		self.all.map{|x|x.value}.include?(code)
	end
end