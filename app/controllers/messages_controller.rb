class MessagesController < ApplicationController
	before_action :logged_in_user

	def index
		@gmail = Gmail.new(current_user.fresh_token)
		@labels = @gmail.labels

		user_inbox = @gmail.inbox
		@messages = user_inbox['messages']
		@inbox_size = user_inbox['resultSizeEstimate']
	end

	def inbox
	end

	private
		def logged_in_user
			unless logged_in?
				flash[:danger] = "Please log in."
				redirect_to root_path
			end
		end

		
end
