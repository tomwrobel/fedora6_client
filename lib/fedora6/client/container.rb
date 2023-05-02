module Fedora6
      class Client::Container < Client

        ARCHIVAL_GROUP="<http://fedora.info/definitions/v4/repository#ArchivalGroup>;rel=\"type\""

        def save(identifier: false, archival_group: false, transaction_uri: false)
            response = Fedora6::Client::Container.create_container(self.config, identifier, archival_group, transaction_uri: transaction_uri)
            validate_response(response)
            # Return new URI
            return response.body
        end

        def get_metadata(uri)
            return Fedora6::Client::Container.get_container(self.config, uri)
        end

        # Class methods

        def self.get_container(config, uri) 
            url = URI.parse(uri)
            response = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
                req = Net::HTTP::Get.new url
                req.basic_auth(config[:user], config[:password])
                http.request(req)
            end
            return response
        end

        def self.create_container(config, identifier, archival_group, transaction_uri: false)
            # create OCFL object
            # curl -X POST -u ${AUTH} -H "Atomic-ID:${TX}" -H "Slug: ${UUID}" -H "${ARCHIVAL_GROUP}" ${BASE}
            url = URI.parse("#{config[:base]}")
            response = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
                req = Net::HTTP::Post.new url
                req.basic_auth(config[:user], config[:password])
                if transaction_uri.present?
                    req['Atomic-ID'] = transaction_uri
                end
                if indentifier.present?
                  req['Slug'] = identifier
                end
                if archival_group
                  req['Link'] = ARCHIVAL_GROUP
                end
                req.content_type = 'text/turtle'
                http.request(req)
            end
            return response
        end

      end
end