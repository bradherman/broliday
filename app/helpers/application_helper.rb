module Sinatra
	module Helpers
    	def current_user
      		User.first(:cell => session[:user])
		end
	end
end