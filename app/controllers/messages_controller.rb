class MessagesController < ApplicationController

	def index
		@labels = Gmail.new(current_user.fresh_token).labels
	end

	def inbox
	end

		
end
