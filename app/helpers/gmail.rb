class Gmail

	def initialize(token)
		@client = Google::APIClient.new(:application_name => "Email Chat")
		@client.authorization.access_token = token
		@service = @client.discovered_api('gmail', 'v1')
	end 

	def labels 
		results = @client.execute!(
			:api_method => @service.users.labels.list,
  			:parameters => { :userId => 'me' },
  			:headers => {'Content-Type' => 'application/json'})
		JSON.parse(results.body)['labels']
	end 

	def inbox
		results = @client.execute!(
    		:api_method => @service.users.messages.list,
    		:parameters => {'userId' => 'me', 'labelIds' => ['INBOX'] },
    		:headers => {'Content-Type' => 'application/json'})
  		JSON.parse(results.body)
  	end

	
end