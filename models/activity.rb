class Activity
	include DataMapper::Resource

	property	:id,		Serial
	property	:message,	Text	,	:unique => true

	def personalize(to)
		m = message
		target = User.first(:cell.not => to, :offset => rand(User.count-1)) if message.scan(/\[\[target\]\]/).present?
		other = User.first(:cell.not => [to, (target rescue "")], :offset => rand(User.count-2)) if self.message.scan(/\[\[other\]\]/).present?
		
		m.gsub!(/\[\[target\]\]/, target) if target
		m.gsub!(/\[\[other\]\]/, other) if other
		m
	end

	def self.random(to)
		code = Code.create
		m = Activity.first(:offset => rand(Activity.count)).personalize(to)
		code.message = m
		code.name = (User.first(:cell => to).name rescue nil)
		code.save
		"Get a pic of ".concat(m).concat(Activity.instructions(code.id))
	end

	def self.instructions(code)
		" Go to http://broliday.herokuapp.com/upload/#{code} to send to the stream."
	end
end