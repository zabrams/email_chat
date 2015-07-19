module MessagesHelper
	SUBJECT_MAX_LENGTH = 35

	def shorten(body)
		if body.length > SUBJECT_MAX_LENGTH
			truncated_body = body[0,SUBJECT_MAX_LENGTH]
		else
			body
		end
	end

	#take text before the 'gmail extra' tag
	def remove_history(body)
	  if matched_body = /(.*?)<div class=\"gmail_extra\">/m.match(body)
	    matched_body[1]
	  else
	    body
	  end
	end

	def get_name(from)
		from.gsub(/<.*?>/, "").rstrip.gsub(/\A"|"\Z/, '')
	end

	def get_email(from)
		/<(.*)>/.match(from).to_s.gsub(/[<>]/, "")
	end

	def get_initials(from)
		initials = ""
		name = get_name(from).split(" ")
		name.each do |name|
			initials += name.first.capitalize
		end
		return initials[0,2]
	end

	def group_participants(thread)
		@participants = []
		if to_field = thread[:to]
			build_participant_list(to_field)
		end

		if cc_field = thread[:cc]
			build_participant_list(cc_field)
		end
		return @participants
	end

	def build_participant_list(field)
		members = field.split(",").map(&:strip)
		members.each do |person|
			#to_email = get_email(person)
			#unless current_user[:email] == to_email 
			name_only = get_name(person)
			@participants.push(name_only)
			#end
		end
	end

	def group_threads_by_participants(threads)
		#go through each thread and order the participants
		#then check is the array of participants are equal
		#if they are, add the thread, if not create new one

		#TODO ADD FROM PERSON TO PARTICIPANT LIST AND CLEAN UP
		#_PARTICIPANT_CIRCLE CODE
		@participant_key = {}
		i = 1
		threads.each do |date, thread|
			group_participants(thread)
			sorted_names = @participants.sort
			if @participant_key.blank?
				@participant_key.merge!( sorted_names => i )
			else
				exist = false
				@participant_key.each do |existing_participants, existing_thread|
					if sorted_names == existing_participants
						exist = true
					end 
				end 
				unless exist
					i += 1
					@participant_key.merge!( sorted_names => i )
				end
			end
		end
	end


	def sort_read_and_unread(thread_hash)
		unread = false
		append = false
		ru_type = nil

		@read_and_unread = { "unread" => {}, "read" => {} }
		thread_hash.each do |names, date_thread|
			date_thread.each do |date, thread|
				if thread[:labels].include?("UNREAD")
					unread = true
				end
			end

			if unread
				@read_and_unread['unread'].merge!( names => date_thread )
			else
				@read_and_unread['read'].merge!( names => date_thread )
			end
		end
	end
end




