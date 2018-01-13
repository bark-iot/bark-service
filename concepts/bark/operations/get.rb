require 'securerandom'

class Bark < Sequel::Model(DB)
  class Get < Trailblazer::Operation
    extend Contract::DSL

    step :model!
    step Contract::Build()
    step Contract::Validate()
    step :log_success
    failure  :log_failure

    contract do
      property :house_id, virtual: true
      property :id, virtual: true

      validation do
        required(:house_id).filled
        required(:id).filled
      end
    end

    def model!(options, params:, **)
      options['model'] = Bark.where(house_id: params[:house_id]).where(id: params[:id]).first
      options['model']
    end

    def log_success(options, params:, model:, **)
      LOGGER.info "[#{self.class}] Found bark with params #{params.to_json}. Bark: #{Bark::Representer.new(model).to_json}"
    end

    def log_failure(options, params:, **)
      LOGGER.info "[#{self.class}] Failed to find bark with params #{params.to_json}"
    end
  end
end