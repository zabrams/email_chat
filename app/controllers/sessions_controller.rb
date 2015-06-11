class SessionsController < ApplicationController
	layout false

	def new
	end

	def create 
		@auth = auth_hash['credentials']
		email = auth_hash['info']['email']
		@user = User.find_by(email: email) || create_user(auth_hash)
		if @user
			flash[:success] = "Signed in!"
		else
			flash[:danger] = "Oops, something went wrong!"
			redirect_to root_path
		end
	end

	def create_user(auth_hash)
		User.create(
			name: auth_hash['info']['name'],
			email: auth_hash['info']['email'],
			access_token: auth_hash['credentials']['token'],
			refresh_token: auth_hash['credentials']['refresh_token'],
			expires_at: Time.at(auth_hash['credentials']['expires_at']).to_datetime)
	end

	private
		def auth_hash
			request.env['omniauth.auth']
		end
end
