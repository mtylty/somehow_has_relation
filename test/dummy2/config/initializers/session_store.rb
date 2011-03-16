# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_dummy2_session',
  :secret      => 'fb5f1620f8bd7072fcd34b078a561dc9bb4f46792169ea20263ca764555a792607532d3145c954057d6f2f088500e67735bc7f122ed7488204bd9c0262332936'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
