require 'securerandom'

class Bark < Sequel::Model(DB)
  class Create < Trailblazer::Operation
    extend Contract::DSL

    step Model(Bark, :new)
    step Contract::Build()
    step Contract::Validate()
    step :set_timestamps
    step :validate_trigger
    step :validate_action
    step Contract::Persist()
    step :notify
    step :log_success
    failure  :log_failure

    contract do
      property :house_id
      property :trigger_id
      property :action_id
      property :title
      property :mappings
      property :settings
      property :authorization_header, virtual: true

      validation do
        required(:house_id).filled
        required(:trigger_id).filled
        required(:action_id).filled
        required(:title).filled
        required(:authorization_header).filled
      end
    end

    def set_timestamps(options, model:, **)
      timestamp = Time.now
      model.created_at = timestamp
      model.updated_at = timestamp
    end

    def validate_trigger(params:, **)
      result = Trigger::ValidateHouseId.(id: params[:trigger_id], house_id: params[:house_id], authorization_header: params[:authorization_header])
      result.success?
    end

    def validate_action(params:, **)
      result = Action::ValidateHouseId.(id: params[:trigger_id], house_id: params[:house_id], authorization_header: params[:authorization_header])
      result.success?
    end

    def notify(options, params:, model:, **)
      REDIS.publish 'barks', {type: 'created', bark: model.values}.to_json
    end

    def log_success(options, params:, model:, **)
      LOGGER.info "[#{self.class}] Created bark with params #{params.to_json}. Bark: #{Bark::Representer.new(model).to_json}"
    end

    def log_failure(options, params:, **)
      LOGGER.info "[#{self.class}] Failed to create bark with params #{params.to_json}"
    end
  end
end