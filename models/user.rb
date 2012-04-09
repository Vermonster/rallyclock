require 'securerandom'

class User < Sequel::Model
  plugin :validation_helpers
  plugin :json_serializer

  one_to_many :entries
 
  attr_accessor :password

  set_allowed_columns :username, :password, :email, :api_key

  def before_create
    encrypt_password
    generate_api_key
  end

  def self.authenticate(email, password)
    user = User.first(email: email)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

  def generate_api_key
    self.api_key = SecureRandom.base64(15).tr('+/=lIO0', 'pqrsxyz')
  end

  def validate
    super
    validates_presence :email
    validates_presence :password if new?
    validates_unique :email
  end
end
