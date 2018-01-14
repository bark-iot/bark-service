require 'rest-client'

class Trigger
  class ValidateHouseId < Trailblazer::Operation
    extend Contract::DSL

    step :model!
    step Contract::Build()
    step Contract::Validate()
    step :log_success
    failure  :log_failure

    contract do
      property :id, virtual: true
      property :house_id, virtual: true
      property :authorization_header, virtual: true

      validation do
        required(:id).filled
        required(:house_id).filled
        required(:authorization_header).filled
      end
    end

    def model!(options, params:, **)
      begin
        response = RestClient.get("http://lb/houses/#{params[:house_id]}/triggers/#{params[:id]}/validate", headers={'Authorization' => params[:authorization_header]})
      rescue RestClient::Unauthorized, RestClient::Forbidden, RestClient::UnprocessableEntity, RestClient::NotFound => err
        return false
      else
        options['model'] = JSON.parse(response.body)
        return true
      end
    end

    def log_success(options, params:, model:, **)
      LOGGER.info "[#{self.class}] Found valid trigger with params #{params.to_json}. House: #{options['model'].to_s}"
    end

    def log_failure(options, params:, **)
      LOGGER.info "[#{self.class}] Failed to find valid trigger with params #{params.to_json}"
    end
  end
end