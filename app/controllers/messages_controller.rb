class MessagesController < ApplicationController
	before_action :logged_in_user, :connect

	def index
		if session[:thread_hash]
			@thread_hash = session[:thread_hash]
		else
			connect
			retrieve_messages
			group_msg_by_thread
			session[:thread_hash] = @thread_hash
		end
	end

	def inbox
	end

	def show
		thread_id = params[:sender]
		
		msgs = session[:thread_hash][thread_id]
		additional_threads = @gmail.get_threads(thread_id)

		

		if additional_threads
			all_threads = msgs.merge(additional_threads)
			@ordered_threads = all_threads.sort_by { |k, v| k.to_datetime }
		else
			@ordered_threads = msgs
		end

		group_threads_by_participants(@ordered_threads)
		
		@subject = get_attribute(msgs)[:subject]
		
	end

	#def refresh_gmail
	#	retrieve_messages
	#	group_msg_by_thread
	#	session[:thread_hash] = @thread_hash
	#	redirect_to :back
	#end

	private
		def logged_in_user
			unless logged_in?
				flash[:danger] = "Please log in."
				redirect_to root_path
			end
		end

		def connect
			unless @gmail
				@gmail = Gmail.new(current_user.fresh_token)
			end
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

		#THIS IS UNUSED 
		#def group_msg_by_sender 
		#	@sender_hash = {}
		#	@details.each do |sender, data|
		#		name = data[:from]
		#		id = rand(10 ** 10)
		#		if @sender_hash.blank?
		#			@sender_hash.merge!( id => { data[:date] => data } )
		#		else
		#			exist = false
		#			@sender_hash.each do |hash_id, email_hash|
		#				@existing_id = hash_id
		#				sender = get_attribute(email_hash)[:from]
		#				if name == sender
		#					exist = true
		#				else 
		#					exist = false
		#				end 
		#			end

		#			if exist
		#				@sender_hash[@existing_id].merge!( data[:date] => data )
		#			else
		#				@sender_hash.merge!( id => { data[:date] => data } )
		#			end
		#		end
		#	end
		#end

		def get_attribute(hash)
			#takes the data hash and returns first k, v 
			#as an array. The first because its the most 
			# recent msg. Then we take the email_hash
			#and use that to ask for a specific item. 
			hash.first.last
		end

		#Create Similar variable for retrieving messages
		
end
