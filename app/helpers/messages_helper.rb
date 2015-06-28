module MessagesHelper
	MAX_LENGTH = 200

	def shorten(body)
		if body.length > MAX_LENGTH
			truncated_body = body[0,MAX_LENGTH]
		else
			body
		end
	end

	def get_name(from)
		from.gsub(/<.*?>/, "").rstrip.gsub(/\A"|"\Z/, '')
	end

	def get_initials(from)
		initials = ""
		name = get_name(from).split(" ")
		name.each do |name|
			initials += name.first.capitalize
		end
		return initials[0,2]
	end

	def number_of_participants(thread)
		num = 0
		if to_field = thread[:to]

			num += to_field.split(",").count
		end

		if cc_field = thread[:cc]
			num += cc_field.split(",").count
		end

		unless num > 1
			num = 'No'
		end

		return num
	end
	
end
