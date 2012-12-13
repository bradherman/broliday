# Defines our constants
PADRINO_ENV  = ENV['PADRINO_ENV'] ||= ENV['RACK_ENV'] ||= 'development'  unless defined?(PADRINO_ENV)
PADRINO_ROOT = File.expand_path('../..', __FILE__) unless defined?(PADRINO_ROOT)

MOGREET_URI = "https://api.mogreet.com/moms/transaction.send"
MOGREET_CLIENT_ID = "1320"
MOGREET_TOKEN = "61d5ae55854a90d390cf8adcd49d8a0a"
MOGREET_SMS_CAMPAIGN = "28453"

S3_ACCESS_KEY = ENV["S3_ACCESS_KEY"] || "AKIAIKL4ZXXQNRXVY6AA"
S3_SECRET = ENV["S3_SECRET"] || "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"

# Load our dependencies
require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.require(:default, PADRINO_ENV)

##
# ## Enable devel logging
#
# Padrino::Logger::Config[:development][:log_level]  = :devel
# Padrino::Logger::Config[:development][:log_static] = true
#
# ## Configure your I18n
#
# I18n.default_locale = :en
#
# ## Configure your HTML5 data helpers
#
# Padrino::Helpers::TagHelpers::DATA_ATTRIBUTES.push(:dialog)
# text_field :foo, :dialog => true
# Generates: <input type="text" data-dialog="true" name="foo" />
#
# ## Add helpers to mailer
#
# Mail::Message.class_eval do
#   include Padrino::Helpers::NumberHelpers
#   include Padrino::Helpers::TranslationHelpers
# end

##
# Add your before (RE)load hooks here
#
Padrino.before_load do
end

##
# Add your after (RE)load hooks here
#
Padrino.after_load do
  DataMapper.finalize
end

Padrino.load!
