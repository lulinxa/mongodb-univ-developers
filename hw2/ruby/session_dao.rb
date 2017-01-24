require 'securerandom'
require 'pry'
require 'pry-nav'

# The session Data Access Object handles
# interactions with the sessions collection
class SessionDAO
  attr_accessor :db, :sessions

  def initialize(database)
    @db = database
    @sessions = database[:sessions]
  end

  # will start a new session id by adding a
  # new document to the sessions collection
  # returns the sessionID or nil
  def start_session(username)
    session_id = SecureRandom.hex
    session = { username: username, _id: session_id }

    begin
      @sessions.insert_one(session)
    rescue
      p 'Unexpected error on start_session'
      return nil
    end

    session[:_id]
  end

  # will send a new user session by deleting from sessions table
  def end_sessions(session_id)
    session_id ? sessions.find(_id: session_id).remove : nil
  end

  # if there is a valid session, it is returned
  def get_session(session_id)
    binding.pry
    session_id ? sessions.find(_id: session_id) : nil
  end

  # get the username of the current session, or None if the session is not valid
  def get_username(session_id)
    binding.pry
    session = get_session(session_id)
    session ? session[:username] : nil
  end

  def get_random_str(num_chars)
    SecureRandom.hex(num_chars)
  end
end
