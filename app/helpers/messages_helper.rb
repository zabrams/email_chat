module MessagesHelper
	SUBJECT_MAX_LENGTH = 50

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
		if to_field = thread[:to]
			tos = to_field.split(",")
			tos.each do |person|
				to_email = get_email(person)
				unless current_user[:email] == to_email
					name_only = get_name(person)
					@participants.push(name_only)
				end
			end
			@num += tos.count
		end

		if cc_field = thread[:cc]
			ccs = cc_field.split(",")
			ccs.each do |person|
				cc_email = get_email(person)
				unless current_user[:email] == cc_email
					name_only = get_name(person)
					@participants.push(name_only)
				end
			end
			@num += ccs.count
		end
	end
end
