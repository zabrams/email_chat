class MessagesController < ApplicationController
	before_action :logged_in_user

	def index
		if session[:thread_hash]
			@thread_hash = session[:thread_hash]
			if params[:refresh] == true 
				refresh_gmail
			end
		else
			connect
			refresh_gmail
		end
		#@labels = @gmail.labels
	end

	def inbox
	end

	def show
		@thread_id = params[:sender]
		@msgs = session[:thread_hash][@thread_id]
		#debugger
		@sender = get_attribute(@msgs)[:from]
		#@sender_messages = @sender_hash[sender]
	end

	def refresh_gmail
		retrieve_messages
		session[:thread_hash] = @thread_hash
		redirect_to 'messages/index'
	end

	private
		def logged_in_user
			unless logged_in?
				flash[:danger] = "Please log in."
				redirect_to root_path
			end
		end

		def connect
			@gmail = Gmail.new(current_user.fresh_token)
		end

		def retrieve_messages
			@details = { }
			messages = @gmail.inbox['messages']
			messages.each do |msg| 
				@details.merge!(msg['id'] =>  @gmail.get_details(msg['id'])) 
			end
		end
		
		def group_msg_by_thread
			@thread_hash = {}
			@details.each do |msg_id, data|
				threadId = data[:threadId]
				if @thread_hash.blank?
					@thread_hash.merge!( threadId => { data[:date] => data } )
				else
					exist = false
					@thread_hash.each do |thread_id, email_hash|
						@existing_id = thread_id
						if threadId == @existing_id
							exist = true
						else
							exist = false
						end
					end

					if exist
						@thread_hash[@existing_id].merge!( data[:date] => data )
					else
						@thread_hash.merge!( threadId => { data[:date] => data } )
					end
				end
			end
		end

		#FIGURE OUT HOW TO GET DETAILS OF MESSAGES ONLY ONE TIME
		#Take all messages - iterate through for unique emails - 
		#then record the message IDs for all messages tied to that email
		def group_msg_by_sender 
			#take @details and sort into has with email at the key
			@sender_hash = {}
			@details.each do |sender, data|
				name = data[:from]
				id = rand(10 ** 10)
				if @sender_hash.blank?
					@sender_hash.merge!( id => { data[:date] => data } )
				else
					exist = false
					@sender_hash.each do |hash_id, email_hash|
						@existing_id = hash_id
						sender = get_attribute(email_hash)[:from]
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
