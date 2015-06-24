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
		@sender_id = params[:sender].to_i
		@msgs = session[:sender_hash][@sender_id]
		@sender = get_attribute(@msgs)[:from]
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
				id = rand(10 ** 10)
				if @sender_hash.blank?
					@sender_hash.merge!( id => { data[:date] => data } )
				else
					exist = false
					@sender_hash.each do |hash_id, email_hash|
						@existing_id = hash_id
						sender = get_attribute(email_hash)[:sender]
						if name == sender
							exist = true
						else
							exist = false
						end 
					end

					if exist
						@sender_hash[@existing_id].merge!( data[:date] => data )
					else
						@sender_hash.merge!( id => { data[:date] => data } )
					end
				end
			end
		end

		def get_attribute(hash)
			#takes the data hash and returns first k, v 
			#as an array. Then we take the email_hash
			#and use that to ask for a specific item. 
			hash.first.last
		end

		#Create Similar variable for retrieving messages
		
end
