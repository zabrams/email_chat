class Gmail

	def initialize(token)
		@client = Google::APIClient.new(:application_name => "Email Chat")
		@client.authorization.access_token = token
		@service = @client.discovered_api('gmail', 'v1')
    @plus = @client.discovered_api('plus', 'v1')
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

  def get_details(id)
  		results = @client.execute!(
   			:api_method => @service.users.messages.get,
   			:parameters => {'userId' => 'me', 'id' => id, 'format' => 'full'},
    		:headers => {'Content-Type' => 'application/json'})
  		data = JSON.parse(results.body)
  		{ subject: get_gmail_attribute(data, 'Subject'),
    	from: get_gmail_attribute(data, 'From'),
    	body: get_gmail_body(data), 
      sender: get_gmail_attribute(data, 'Return-Path'),
      date:  get_gmail_attribute(data, 'Date'),
      #data: data
      }
  end

  def get_messages_from(sender)
      results = @client.execute!(
        :api_method => @service.users.messages.list,
        :parameters => {'userId' => 'me', 'q' => "from:#{sender}" },
        :headers => {'Content-Type' => 'application/json'})
      JSON.parse(results.body)
  end

  def get_gmail_attribute(gmail_data, attribute)
  		headers = gmail_data['payload']['headers']
  		array = headers.reject { |hash| hash['name'] != attribute }
  		array.first['value']
	end

	def get_gmail_body(gmail_data)
  		#raw text version 
      body = gmail_data['payload']['parts'].first['body']['data']
      #html version
      #body = gmail_data['payload']['parts'].last['body']['data']
  		Base64.urlsafe_decode64(body)
	end


	
end