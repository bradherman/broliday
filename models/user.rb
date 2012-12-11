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
end
