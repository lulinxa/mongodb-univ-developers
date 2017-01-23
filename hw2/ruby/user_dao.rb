require 'securerandom'

# user dao class
class UserDAO
  attr_accessor :db, :users, :secret

  def initialize(db)
    @db = db
    @users = db.users
    @secret = 'verysecret'
  end

  def make_salt
    SecureRancom.hex(3)[1..5]
  end

  # implement the function make_pw_hash(name, pw) that returns a hashed password
  # of the format:
  # HASH(pw + salt),salt
  # use sha256
  def make_pw_hash(salt = nil)
    salt ? salt : make_salt
  end
end
