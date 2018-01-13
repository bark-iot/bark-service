require 'rest-client'

class User
  class Get < Trailblazer::Operation
    extend Contract::DSL

    step :model!
    step Contract::Build()
    step Contract::Validate()
    step :log_success
    failure  :log_failure

    contract do
      property :authorization_header, virtual: true

      validation do
        required(:authorization_header).filled
      end
    end

    def model!(options, params:, **)
      begin
        response = RestClient.get('http://lb/users/by_token', headers={'Authorization' => params[:authorization_header]})
      rescue RestClient::Unauthorized, RestClient::Forbidden, RestClient::UnprocessableEntity => err
          return false
      else
        options['model'] = JSON.parse(response.body)
        return true
      end
    end

    def log_success(options, params:, model:, **)
      LOGGER.info "[#{self.class}] Found user with params #{params.to_json}. User: #{options['model'].to_s}"
    end

    def log_failure(options, params:, **)
      LOGGER.info "[#{self.class}] Failed to find user with params #{params.to_json}"
    end
  end
end