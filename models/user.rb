require 'securerandom'

class User < Sequel::Model
  one_to_many :entries
  one_to_many :memberships
  many_to_many :groups, :join_table => :memberships
 
  attr_accessor :password

  set_allowed_columns :username, :password, :email, :api_key

  def rel_path
    "users/#{username}"
  end

  def before_create
    encrypt_password
    generate_api_key
  end

  def self.authenticate(login, password)
    user = User.filter({ email: login }|{ username: login}).first
    user if user && user.gave_correct_password?(password)
  end

  def admin_of?(group)
    # replace with group.admins.include? self
    membership_for(group) && membership_for(group).admin?
  end

  def owner_of?(group)
    membership_for(group) && membership_for(group).owner?
  end

  # options:
  # to=YYYYMMDD
  # from=YYYMMDD
  def filter_entries(options={})
    if options.reject{|k,v|v.nil?}.empty?
      entries
    elsif options[:to] && options[:from]
      entries_dataset.filter("date <= :to AND date >= :from", to: options[:to], from: options[:from]).all
    elsif options[:to]
      entries_dataset.filter("date <= :to", to: options[:to]).all
    elsif options[:from]
      entries_dataset.filter("date >= :from", from: options[:from]).all
    end
  end

  def validate
    super

    validates_presence :email
    validates_presence :username
    validates_presence :password if new?

    validates_unique :email
    validates_unique :username

    validates_format /^\w+$/, :username
    validates_format /@/, :email
  end

  def membership_for(group)
    memberships_dataset.first(group_id: group.id)
  end

  def gave_correct_password?(given)
    password_hash == BCrypt::Engine.hash_secret(given, password_salt)
  end

  private 

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

  def generate_api_key
    self.api_key = SecureRandom.base64(15).tr('+/=lIO0', 'pqrsxyz')
  end

end
