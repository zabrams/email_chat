class MessagesController < ApplicationController

	def index
		@gmail = Gmail.new(current_user.fresh_token)
		@labels = @gmail.labels

		user_inbox = @gmail.inbox
		@messages = user_inbox['messages']
		@inbox_size = user_inbox['resultSizeEstimate']
	end

	def inbox
	end

		
end
