class MessagesController < ApplicationController
	before_action :logged_in_user

	def index
		connect
		retrieve_messages
		group_msg_by_sender
		session[:sender_hash] = @sender_hash
		#@labels = @gmail.labels
	end

	def inbox
	end

	def show
		@sender = params[:sender].to_i
		@msgs = session[:sender_hash][@sender]
		#@sender_messages = @sender_hash[sender]
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
			else
				@gmail
			end 
		end

		def retrieve_messages
			if @details == nil
				@details = { }
				messages = @gmail.inbox['messages']
				messages.each do |msg| 
					@details.merge!(msg['id'] =>  @gmail.get_details(msg['id'])) 
				end
			else
				@details
			end 
		end
		
		#FIGURE OUT HOW TO GET DETAILS OF MESSAGES ONLY ONE TIME
		#Take all messages - iterate through for unique emails - 
		#then record the message IDs for all messages tied to that email
		def group_msg_by_sender 
			#take @details and sort into has with email at the key
			@sender_hash = {}
			@details.each do |sender, data|
				name = data[:sender]
				if @sender_hash.blank?
					id = rand(10 ** 10)
					@sender_hash.merge!( id => { data[:date] => data } )
				else
					exist = false
					@sender_hash.each do |id, email_hash|
						@id = id
						sender = email_hash.first.last[:sender]
						if name == sender
							exist = true
						else
							exist = false
						end 
					end

					if exist
						@sender_hash[@id].merge!( data[:date] => data )
					else
						id = rand(10 ** 10)
						@sender_hash.merge!( id => { data[:date] => data } )
					end
				end
			end
		end

		#Create Similar variable for retrieving messages
		
end
