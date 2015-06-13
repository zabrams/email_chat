module Gmail
	def initialize
		@client = Google::APIClient.new
		@client.authorization.access_token = current_user.fresh_token
		@service = client.discovered_api('gmail', 'v1')
	end 
	
end