module Fedora6
      # Your code goes here...
      class Client::Transaction < Client

        attr_reader :tx_id

        def initialize(config=nil)
            ## Returns tx_id: the transaction id
            super
            #require 'byebug'; byebug
            create_transaction = Client::Transaction.start_transaction(self.config)
            validate_transaction_response(create_transaction)
            @tx_id = create_transaction['Location']
        end

        def get
           return Client::Transaction.get_transaction(@config, @tx_id)
        end

        def keep_alive
            return Client::Transaction.keep_transaction_alive(@config, @tx_id)
        end

        def commit
            return Client::Transaction.commit_transaction(@config, @tx_id)
        end

        def rollback
            return Client::Transaction.rollback_transaction(@config, @tx_id)
        end

        def validate_transaction_response(response)
            unless["201", "204"].include? response.code
                raise Fedora6::APIError.new(response.code, response.body)
            end
        end

        # Class methods

        def self.start_transaction(config)
            # Returns a transaction ID
            url = URI.parse("#{config[:base]}/fcr:tx")
            response = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
                req = Net::HTTP::Post.new url
                req.basic_auth(config[:user], config[:password])
                http.request(req)
            end
            return response
        end

        def self.get_transaction(config, tx_id)
          # Returns a transaction ID
          url = URI.parse("#{config[:base]}/fcr:tx/#{tx_id}")
          response = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
              req = Net::HTTP::Get.new url
              req.basic_auth(config[:user], config[:password])
              http.request(req)
          end
          return response
        end

        def self.keep_transaction_alive(config, tx_id)
            # keeps a transaction that's > 3 minutes long alive
            url = URI.parse("#{config[:base]}/fcr:tx/#{tx_id}")
            response = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
                req = Net::HTTP::Post.new url
                req.basic_auth(config[:user], config[:password])
                http.request(req)
            end
        end

        def self.commit_transaction(config, tx_id)
            # keeps a transaction that's > 3 minutes long alive
            url = URI.parse("#{config[:base]}/fcr:tx/#{tx_id}")
            response = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
                req = Net::HTTP::Put.new url
                req.basic_auth(config[:user], config[:password])
                http.request(req)
            end
        end

        def self.rollback_transaction(config, tx_id)
          url = URI.parse("#{config[:base]}/fcr:tx/#{tx_id}")
            response = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
                req = Net::HTTP::Delete.new url
                req.basic_auth(config[:user], config[:password])
                http.request(req)
            end
        end        
    end
end