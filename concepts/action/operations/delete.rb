class Action
  class Delete < Trailblazer::Operation
    extend Contract::DSL

    step Contract::Build()
    step Contract::Validate()
    step :delete_barks
    step :log_success
    failure  :log_failure

    contract do
      property :action_id, virtual: true

      validation do
        required(:action_id).filled
      end
    end

    def delete_barks(options, params:, **)
      Bark.where(action_id: params[:action_id]).delete
    end

    def log_success(options, params:, **)
      LOGGER.info "[#{self.class}] Deleted barks for action with params #{params.to_json}."
    end

    def log_failure(options, params:, **)
      LOGGER.info "[#{self.class}] Failed to delete barks for action with params #{params.to_json}"
    end
  end
end