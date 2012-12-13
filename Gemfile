source :rubygems

# Server requirements
# gem 'thin' # or mongrel
# gem 'trinidad', :platform => 'jruby'

# Project requirements
gem 'rake'
gem 'sinatra-flash', :require => 'sinatra/flash'

group :development do
  gem 'dm-sqlite-adapter'
end

group :production do
  gem "dm-postgres-adapter"
end

# Component requirements
gem 'aws-s3'
gem 'bcrypt-ruby', :require => "bcrypt"
gem 'dm-validations'
gem 'dm-timestamps'
gem 'dm-migrations'
gem 'dm-constraints'
gem 'dm-aggregates'
gem 'dm-core'
gem 'dm-serializer'
gem 'haml'
gem 'json'
gem 'libxml-ruby'
gem 'mechanize'
gem 'rake'

# Test requirements

# Padrino Stable Gem
gem 'padrino', '0.10.7'

# Or Padrino Edge
# gem 'padrino', :git => 'git://github.com/padrino/padrino-framework.git'

# Or Individual Gems
# %w(core gen helpers cache mailer admin).each do |g|
#   gem 'padrino-' + g, '0.10.7'
# end
