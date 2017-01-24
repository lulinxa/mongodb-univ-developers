require 'sinatra'
require 'sinatra/cookies'
require 'mongo'
require 'cgi'
require 'pry'
require 'pry-nav'
require_relative 'session_dao'
require_relative 'user_dao'

set :port, 8082

database = "blog"
connection_string = "mongodb://localhost:27017/#{database}"
connection = Mongo::Client.new(connection_string)

users = UserDAO.new(connection)
sessions = SessionDAO.new(connection)

# This route is the main page of the blog
get '/' do
  cookie = cookies[:session]
  username = cookies[:username]
  haml :welcome, locals: { cookie: cookie, username: username }
end

# displays the initial blog signup form
get '/signup' do
  haml :signup, locals: { username: '', password: '',
                          password_error: '', email: '',
                          username_error: '', email_error: '',
                          verify_error: '' }
end

# displays the initial blog login form
get '/login' do
  haml :login, locals: { username: '', password: '', login_error: '' }
end

post '/login' do
  username = params[:username]
  password = params[:password]

  p "username submitted [#{username}], pass: #{password}"

  user_record = users.validate_login(username, password)
  if !user_record.nil?
    session_id = sessions.start_session(user_record[:_id])
    redirect to('/internal_error') if session_id.nil?
    cookie = session_id
    cookies[:session] = cookie
    redirect to('/welcome')
  else
    haml :login, locals: { username: CGI.escape(username), password: '',
                           login_error: 'Invalid Login' }
  end
end

get '/internal_error' do
  haml :error_template, localS: { error: 'System has encountered a DB error' }
end

get '/logout' do
  cookie = cookies[:session]
  sessions.end_session(cookie)
  cookies[:session] = ''
  redirect to('/signup')
end

post '/signup' do
  email = params[:email]
  username = params[:username]
  password = params[:password]
  # verify = params[:verify]
  # set these up in case we have an error case
  errors = { username: CGI.escape(username), email: CGI.escape(email) }
  if validate_signup(username, password, verify, email, errors)
    unless users.add_user(username, password, email)
      username_error = 'Username already in use. Please choose another'
      haml :signup, locals: { errors: errors }
    end
    # binding.pry
    session_id = sessions.start_session(username)
    p session_id
    cookies[:session] = session_id
    redirect to('/welcome')
  else
    haml :signup, locals: { errors: errors }
    p 'user did not validate'
  end
end

get '/welcome' do
  # check for a cookie, if present, then extract value
  cookie = cookies[:session]
  # binding.pry
  username = sessions.get_username(cookie)
  unless username
    p "Welcome: can't identify user ... redirecting to signup"
    redirect to('/signup')
  end
  haml :welcome, locals: { username: username }
end

# regexp matches
USER = /^[a-zA-Z0-9_-]{3,20}$/i
PASS = /^.{3,20}$/i
EMAIL = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

# helper method for signup validation
def validate_signup(username, password, verify, email, errors)
  errors[:username_error] = ''
  errors[:password_error] = ''
  errors[:verify_error] = ''
  errors[:email_error] = ''
  unless USER.match(username)
    errors[:username_error] = 'invalid username. try just letters and numbers'
    return false
  end
  unless PASS.match(password)
    errors[:password_error] = 'invalid password.'
    return false
  end
  if password != verify
    errors[:verify_error] = 'password must match'
    false
  end
  unless email.empty?
    unless EMAIL.match(email)
      errors[:email_error] = 'invalid email address'
      return false
    end
  end
  true
end
