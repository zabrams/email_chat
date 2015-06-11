class User < ActiveRecord::Base
	before_save { self.email = email.downcase }
	validates :name, presence: true
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
	#validates :access_token, presence: true
	#validates :refresh_token, presence: true
	#validates :expires_at, presence: true

	  def to_params
	    {'refresh_token' => refresh_token,
	    'client_id' => Rails.application.secrets.client_id,
	    'client_secret' => Rails.application.secrets.client_secret,
	    'grant_type' => 'refresh_token'}
	  end
	 
	  def request_token_from_google
	    url = URI("https://accounts.google.com/o/oauth2/token")
	    Net::HTTP.post_form(url, self.to_params)
	  end
	 
	  def refresh!
	    response = request_token_from_google
	    data = JSON.parse(response.body)
	    update_attributes(
	    access_token: data['access_token'],
	    expires_at: Time.now + (data['expires_in'].to_i).seconds)
	  end
	 
	  def expired?
	    expires_at < Time.now
	  end
	 
	  def fresh_token
	    refresh! if expired?
	    access_token
	  end
	
end
