class User < ActiveRecord::Base
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  validates :email, :presence => true, :uniqueness => true
  validates :email, :format => {
    :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => 'format is invalid'
  }
  has_secure_password# validations: false
  ROLES = %w[admin user]
  
  before_validation(:on => :create) do
    self.send(:autogenerate_password) if password.blank?
  end
  before_create :generate_api_token

  def self.create_token
    SecureRandom.base64(24).to_s.tr('+/=', 'pqrsxyz')
  end

  def self.create_random_password
    SecureRandom.hex(8).to_s
  end

  def self.authenticate_from_hash(auth_hash)
    user = create_with(
      :given_name => auth_hash.given_name, :family_name => auth_hash.family_name,
      :picture => auth_hash.picture, :role => 'user'
    ).find_or_create_by(:email => auth_hash.email) 
    user.reset_token!
    return user
  end

  def reset_token!
    self.update_attributes(:api_token => self.class.create_token)
  end

  private
  def generate_api_token
    self.api_token = self.class.create_token
    autogenerate_password if password.blank?
  end

  def autogenerate_password
    # return if !password.blank?
    passwd = self.class.create_random_password
    self.password = passwd
    self.password_confirmation = passwd
  end
end
