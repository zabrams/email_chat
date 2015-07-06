module MessagesHelper
	SUBJECT_MAX_LENGTH = 35

	def shorten(body)
		if body.length > SUBJECT_MAX_LENGTH
			truncated_body = body[0,SUBJECT_MAX_LENGTH]
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
		@num = 0
		@participants = []
		@participants.push(get_name(thread[:from]))
		if to_field = thread[:to]
			build_participant_list(to_field)
		end

		if cc_field = thread[:cc]
			build_participant_list(cc_field)
		end
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
		@num += members.count
	end

	def group_threads_by_participants(threads)
		#go through each thread and order the participants
		#then check is the array of participants are equal
		#if they are, add the thread, if not create new one

		#TODO ADD FROM PERSON TO PARTICIPANT LIST AND CLEAN UP
		#_PARTICIPANT_CIRCLE CODE
		@participant_threads = {}
		threads.each do |date, thread|
			group_participants(thread)
			sorted_names = @participants.sort
			if @participant_threads.blank?
				@participant_threads.merge!( sorted_names => { date => thread } )
			else
				exist = false
				@participant_threads.each do |existing_participants, existing_thread|
					if sorted_names == existing_participants
						exist = true
					end 
				end 
				if exist
					@participant_threads[sorted_names].merge!( { date => thread } )
				else
					@participant_threads.merge!( sorted_names => { date => thread } )
				end
			end
		end
	end
end




