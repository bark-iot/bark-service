require 'securerandom'

class Bark < Sequel::Model(DB)
  class Delete < Trailblazer::Operation
    extend Contract::DSL

    step Contract::Build()
    step Contract::Validate()
    step :delete
    step :notify
    step :log_success
    failure  :log_failure

    contract do
      property :id, virtual: true
      property :house_id, virtual: true

      validation do
        required(:id).filled
        required(:house_id).filled
      end
    end

    def delete(options, params:, **)
      options['model'] = Bark.where(id: params[:id]).where(house_id: params[:house_id]).first
      return false unless options['model']
      options['model'].destroy
    end

    def notify(options, params:, **)
      REDIS.publish 'barks', {type: 'deleted', bark: {id: params[:id]}}.to_json
    end

    def log_success(options, params:, **)
      LOGGER.info "[#{self.class}] Deleted bark with params #{params.to_json}."
    end

    def log_failure(options, params:, **)
      LOGGER.info "[#{self.class}] Failed to delete bark with params #{params.to_json}"
    end
  end
end