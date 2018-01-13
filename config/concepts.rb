require 'reform'
require 'reform/form/dry'
require 'trailblazer'
require 'trailblazer-loader'

configure do
  Reform::Contract.class_eval { feature Reform::Form::Dry }
  Reform::Form.class_eval { feature Reform::Form::Dry }
  Trailblazer::Loader.new.(concepts_root: '/app/concepts/') { |file| require_relative(file) }
end