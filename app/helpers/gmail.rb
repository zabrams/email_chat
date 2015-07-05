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
      
      get_attribute_hash(data)
  end

  def get_messages_from(sender)
      results = @client.execute!(
        :api_method => @service.users.messages.list,
        :parameters => {'userId' => 'me', 'q' => "from:#{sender}" },
        :headers => {'Content-Type' => 'application/json'})
      JSON.parse(results.body)
  end

  def get_threads(id)
      results = @client.execute!(
        :api_method => @service.users.threads.get,
        :parameters => {'userId' => 'me', 'id' => id, 'format' => 'full'},
        :headers => {'Content-Type' => 'application/json'})
      data = JSON.parse(results.body)['messages']
      thread_messages = {}

      data.each do |message|
        unless message['labelIds'].include?("INBOX")
          hash = get_attribute_hash(message)
          date = hash[:date]
          thread_messages.merge!( date => hash )
        end
      end 

      return thread_messages
  end

  def get_attribute_hash(data)
    { #id: data['id'],
      threadId: data['threadId'],
      subject: get_gmail_attribute(data, 'Subject'),
      from: get_gmail_attribute(data, 'From'),
      snippet:  data['snippet'],
      body: get_gmail_body(data), 
      #sender: get_gmail_attribute(data, 'Return-Path'),
      date:  get_gmail_attribute(data, 'Date'),
      to: get_gmail_attribute(data, 'To'),
      cc: get_gmail_attribute(data, 'Cc'),
      #data: data
      }
  end

  def get_gmail_attribute(gmail_data, attribute)
      headers = gmail_data['payload']['headers']
  		array = headers.reject { |hash| hash['name'].capitalize != attribute.capitalize }
      unless array.blank? 
  		  array.first['value']
      end
	end

	def get_gmail_body(gmail_data)
      #debugger
      payload = gmail_data['payload']
      @body = nil
      @body_plain = nil

      #focusing on .first means we pull html version of email
      if parts = payload['parts']
        while @body == nil && @body_plain == nil
          find_body(parts)
          parts = parts.first['parts']
        end
        if @body
          match(decode(@body))
        elsif @body_plain && @body == nil
          decode(@body_plain)
        end 
      else 
        @body = payload['body']['data']
        decode(@body)
      end 

      #  if body = parts.last['body']['data']
      #    match(decode(body))
      #  elsif body = parts.first['parts'].last['body']['data']
      #    match(decode(body))
      #  else body = parts.first['parts'].first['parts'].last['body']['data']
      #    match(decode(body))
      #  end
      #  #end

      #body = gmail_data['payload']['parts'].first['body']['data']
      #body = gmail_data['payload']['parts'].first['parts'].first['body']['data']
      #html version
      #body = gmail_data['payload']['parts'].last['body']['data']
	end

  def decode(body)
    Base64.urlsafe_decode64(body.to_s)
  end

  #take text before the 'gmail extra' tag
  def match(body)
    if matched_body = /(.*?)<div class=\"gmail_extra\">/m.match(body)
      matched_body[1]
    else
      body
    end
  end

  #Only take the first instance - 
  #might cause issues with multipart emails...
  def find_body(parts)
    parts.each do |part|
      part.each do |key, value|
        if value == 'text/html' && @body == nil
          @body = part['body']['data']
        elsif value == 'text/plain' && @body_plain == nil
          @body_plain = part['body']['data']
        end
      end
    end
  end


end