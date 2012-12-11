class User
	include DataMapper::Resource
	include DataMapper::Validate

	property :id,		Serial
	property :name,		String	,	:required => true
	property :cell,		String	,	:required => true	,	:unique => true

	property :points,	Integer	,	:default => 5

	validates_with_method	:check_code, :message => "Invalid code"

	def check_code
		Code.include?(self.code) ? true : false
	end

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
end
