class MessagesController < ApplicationController
	before_action :logged_in_user

	def index
		connect
		retrieve_messages
		group_msg_by_sender
		#@labels = @gmail.labels
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

		def connect
			if @gmail == nil
				@gmail = Gmail.new(current_user.fresh_token)
			end 
		end

		def retrieve_messages
			if @details == nil
				@details = { }
				messages = @gmail.inbox['messages']
				messages.each do |msg| 
					@details.merge!(msg['id'] =>  @gmail.get_details(msg['id'])) 
				end
			end 
		end
		
		#FIGURE OUT HOW TO GET DETAILS OF MESSAGES ONLY ONE TIME
		#Take all messages - iterate through for unique emails - 
		#then record the message IDs for all messages tied to that email
		def group_msg_by_sender 
			#take @details and sort into has with email at the key
			@sender_hash = {}
			@details.each do |id, data|
				name = data[:sender]
				if @sender_hash.blank?
					@sender_hash.merge!( name => { data[:date] => data } )
				else
					exist = false
					@sender_hash.each do |sender, email|
						if name == sender
							exist = true
						else
							exist = false
						end 
					end

					if exist
						@sender_hash[name].merge!( data[:date] => data )
					else
						@sender_hash.merge!( name => { data[:date] => data } )
					end
				end
			end
		end

		#Create Similar variable for retrieving messages
		
end
