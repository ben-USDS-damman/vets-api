# frozen_string_literal: true
require 'common/client/configuration/soap'

module MVI
  class Configuration < Common::Client::Configuration::SOAP
    def base_path
      MVI::Settings::URL
    end

    def service_name
      'MVI'
    end

    def ssl_options
      if MVI::Settings::SSL_CERT && MVI::Settings::SSL_KEY
        {
          client_cert: MVI::Settings::SSL_CERT,
          client_key: MVI::Settings::SSL_KEY
        }
      else
        nil
      end
    end

    def connection
      Faraday.new(base_path, headers: base_request_headers, request: request_options, ssl: ssl_options) do |conn|
        conn.request :soap_headers
        conn.response :soap_parser
        conn.use :breakers
        conn.adapter Faraday.default_adapter
      end
    end
  end
end
