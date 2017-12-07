# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_simple_server_for_winxp_session',
  :secret      => '9ff80bbbc31b5bff0ad834515fa3b76a4c7a5118319cbd06d4f21a6b459a2c8c3cbc13fd52ab45a9938b8ff8be6ac4953291d2fc22f167def924e3cada5625a8'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
