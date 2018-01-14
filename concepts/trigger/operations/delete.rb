class Trigger
  class Delete < Trailblazer::Operation
    extend Contract::DSL

    step Contract::Build()
    step Contract::Validate()
    step :delete_barks
    step :log_success
    failure  :log_failure

    contract do
      property :trigger_id, virtual: true

      validation do
        required(:trigger_id).filled
      end
    end

    def delete_barks(options, params:, **)
      Bark.where(trigger_id: params[:trigger_id]).delete
    end

    def log_success(options, params:, **)
      LOGGER.info "[#{self.class}] Deleted barks for trigger with params #{params.to_json}."
    end

    def log_failure(options, params:, **)
      LOGGER.info "[#{self.class}] Failed to delete barks for trigger with params #{params.to_json}"
    end
  end
end