# Seed add you the ability to populate your db.
# We provide you a basic shell for interaction with the end user.
# So try some code like below:
#
#   name = shell.ask("What's your name?")
#   shell.say name
#
# email     = shell.ask "Which email do you want use for logging into admin?"
# password  = shell.ask "Tell me the password to use:"

# shell.say ""

# account = Account.create(:email => email, :name => "Foo", :surname => "Bar", :password => password, :password_confirmation => password, :role => "admin")

# if account.valid?
#   shell.say "================================================================="
#   shell.say "Account has been successfully created, now you can login with:"
#   shell.say "================================================================="
#   shell.say "   email: #{email}"
#   shell.say "   password: #{password}"
#   shell.say "================================================================="
# else
#   shell.say "Sorry but some thing went wrong!"
#   shell.say ""
#   account.errors.full_messages.each { |m| shell.say "   - #{m}" }
# end

# shell.say ""

Activity.create(:message => "someone talking incessantly about Notre Dame football.")
Activity.create(:message => "the best dancer at the company.")
Activity.create(:message => "the most hipster outfit at the party.")
Activity.create(:message => "someone you know you can beat at ping pong.")
Activity.create(:message => "someone you've shot a nerf gun at.")
Activity.create(:message => "someone with a British accent.")
Activity.create(:message => "a 'bro'.")
Activity.create(:message => "someone who doesn't want their picture taken.")
Activity.create(:message => "someone laughing.")
Activity.create(:message => "a tattoo.")
Activity.create(:message => "someone who's had one too many drinks.")
Activity.create(:message => "<target> and <other> in some kind of argument.")
Activity.create(:message => "<target> looking at his own reflection.")
Activity.create(:message => "<target> running his fingers through his hair.")
Activity.create(:message => "someone else running their fingers through <target>'s hair.")