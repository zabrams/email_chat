module MessagesHelper
	MAX_LENGTH = 200

	def shorten(body)
		if body.length > MAX_LENGTH
			truncated_body = body[0,MAX_LENGTH]
		else
			body
		end
	end
	
end
