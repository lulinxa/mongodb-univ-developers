require 'sinatra'
require 'sinatra/cookies'
require 'mongo'
require 'cgi'
require 'pry'
require 'pry-nav'
require_relative 'session_dao'
require_relative 'user_dao'

database = "blog"
connection_string = "mongodb://localhost:27017/#{database}"
connection = Mongo::Client.new(connection_string)

users = UserDAO.new(connection)
sessions = SessionDAO.new(connection)

# This route is the main page of the blog
get '/' do
  cookie = cookies[:session]
  username = cookies[:username]
  haml :welcome, :locals => { :cookie => cookie, :username => username }
end

# displays the initial blog signup form
get '/signup' do
  haml :signup, :locals => { :username => "", :password => "",
                             :password_error => "", :email => "",
                             :username_error => "", :email_error => "",
                             :verify_error => "" }
end

# displays the initial blog login form
get '/login' do
  haml :login, :locals => { :username => "", :password => "", :login_error => "" }
end

post '/login' do
  username = params[:username]
  password = params[:password]

  p "username submitted [#{username}], pass: #{password}"

  user_record = users.validate_login(username, password)
  if user_record
    session_id = sessions.start_session(user_record[:_id])
    if session_id == nil
      redirect to('/internal_error')
    end
    cookie = session_id
    cookies[:session] = cookie
    redirect to('/welcome')
  else
    haml :login, :locals => { :username => CGI::escape(username), :password => "",
                              :login_error => "Invalid Login"}
  end
end

get '/internal_error' do
  haml :error_template, :locals => { :error => "System has encountered a DB error" }
end

get '/logout' do
  cookie = cookies[:session]
  sessions.end_session(cookie)
  cookies[:session] = ""
  redirect to('/signup')
end

post '/signup' do
  email = params[:email]
  username = params[:username]
  password = params[:password]
  verify = params[:verify]
  # set these up in case we have an error case
  errors = {'username': CGI::escape(username), 'email': CGI::escape(email)}
  if true # validate_signup(username, password, verify, email, errors)
    if !users.add_user(username, password, email)
      username_error = "Username already in use. Please choose another"
      haml :signup, :locals => { :errors => errors }
    end
    binding.pry
    session_id = sessions.start_session(username)
    p session_id
    cookies[:session] = session_id
    redirect to('/welcome')
  else
    haml :signup, :locals => { :errors => errors }
    p 'user did not validate'
  end
end

get '/welcome' do
  # check for a cookie, if present, then extract value
  cookie = cookies[:session]
  binding.pry
  username = sessions.get_username(cookie)
  unless username
    p "Welcome: can't identify user ... redirecting to signup"
    redirect to('/signup')
  end
  haml :welcome, :locals => { :username => username }
end
