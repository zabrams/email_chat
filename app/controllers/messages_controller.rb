class MessagesController < ApplicationController
	before_action :logged_in_user, :connect
	respond_to :html, :json

	def index
		connect
		retrieve_messages
		array = []
		array.push(@ordered_thread_hash)
		respond_with array
	end

	def show
		thread_id = params[:thread]
		
		msgs = session[:thread_hash][thread_id]
		additional_threads = @gmail.get_threads(thread_id)

		if additional_threads
			all_threads = msgs.merge(additional_threads)
			@ordered_threads = all_threads.sort_by { |k, v| k.to_datetime }
		else
			@ordered_threads = msgs
		end

		session[:show_thread_msgs] = @ordered_threads

		@ordered_threads.each do |date, thread|
			@max_members = 0
			group_participants(thread)
			if @num > @max_members
				@max_members = @num
				@members = @participants
			end
		end

		group_threads_by_participants(@ordered_threads)
		session[:participants] = @participant_key
		#sort_read_and_unread(@participant_threads)		
		@subject = get_attribute(msgs)[:subject]
	end

	def refresh_gmail
		session[:thread_hash] = nil
		redirect_to messages_url
	end

	def filter
		all_threads = session[:show_thread_msgs]
		participant_key = session[:participants]
		name_num = params[:filter].to_i
		participant_key.each do |names, key|
			if key == name_num
				@members = names
			end
		end
		@ordered_threads = {}
		all_threads.each do |date, thread|
			group_participants(thread)
			if @members == @participants.sort
				@ordered_threads.merge!( date => thread )
			end 
		end
		@subject = get_attribute(@ordered_threads)[:subject]
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
			thread_hash = { }
			messages = @gmail.inbox['messages']
			messages.each do |msg|
				details = @gmail.get_details(msg['id'])
				threads = { details[:date] => details }
				additional_threads = @gmail.get_threads(msg['threadId'])
				if additional_threads
					threads = threads.merge(additional_threads)
				end
				if thread_hash.blank?
					thread_hash.merge!( msg['threadId'] => threads )
				else 
					exist = false
					thread_hash.each do |msg_id, threads|
						if msg['threadId'] == msg_id
							exist = true
						else
							exist = false
						end 
					end

					if exist
						thread_hash[msg['threadId']].merge!( threads )
					else
						thread_hash.merge!( msg['threadId'] => threads )
					end
				end
			end

			@ordered_thread_hash = { }
			thread_hash.each do |msg_id, threads|
				ordered_thread = threads.sort_by { |k, v| k.to_datetime }
				@ordered_thread_hash.merge!( msg_id => ordered_thread)
			end
		end
		
		def group_msg_by_thread
			@thread_hash = {}
			@details.each do |msg_id, data|
				threadId = data[:threadId]
				if @thread_hash.blank?
					@thread_hash.merge!( threadId => data )
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
						@thread_hash[@existing_id].merge!( data )
					else
						@thread_hash.merge!( threadId => data )
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
