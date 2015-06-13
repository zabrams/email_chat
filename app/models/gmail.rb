require 'google/api_client'

class Gmail

	def initialize(token)
		@client = Google::APIClient.new
		@client.authorization.access_token = token
		@service = @client.discovered_api('gmail')
	end 

	def labels 
		result = @client.execute!(
			:api_method => @service.users.labels.list,
  			:parameters => { :userId => 'me' },
  			:headers => { 'Content-Type' => 'application/json' })
		JSON.parse(result.body)
	end 

	
end