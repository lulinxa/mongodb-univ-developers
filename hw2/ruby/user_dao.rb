require 'securerandom'
require 'mongo'
require 'bcrypt'

# user dao class
class UserDAO
  attr_accessor :db, :users, :secret

  def initialize(db)
    @db = db
    @users = db[:users]
    @secret = 'verysecret'
  end

  def make_salt
    SecureRandom.hex(3)
  end

  # implement the function make_pw_hash(name, pw) that returns a hashed password
  # of the format:
  # HASH(pw + salt),salt
  # using bcrypt
  def make_pw_hash(pw, salt = nil)
    salt = make_salt unless salt
    BCrypt::Password.create(pw + salt) + ',' + salt
  end

  # Validates a user login. Returns user record or nil
  def validate_login(username, password)
    user = nil
    begin
      user = @users.find_one(_id: username)
      # you will need to retrieve right document from the users collection.
      p 'This space intentionally left blank.'
    rescue
      p 'Unable to query database for user'
    end

    if user.nil?
      p 'User not in database'
      return nil
    end

    salt = user['password'].split(',')[1]

    if user['password'] != make_pw_hash(password, salt)
      p 'user password is not a match'
      return nil
    end
    # Looks good
    user
  end

  # creates a new user in the users collection
  def add_user(username, password, email)
    password_hash = make_pw_hash(password)
    user = { _id: username, password: password_hash }
    user['email'] = email unless email.empty?
    begin
      # You need to insert the user into the users collection.
      @users.insert_one(user)
      p 'This space intentionally left blank.'
    rescue
      p 'Error MongoDB'
      return nil
    end
    true
  end
end
