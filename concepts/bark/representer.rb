require 'roar/decorator'
require 'roar/json'

class Bark < Sequel::Model(DB)
  class Representer < Roar::Decorator
      include Roar::JSON
      defaults render_nil: true

      property :id
      property :house_id
      property :trigger_id
      property :action_id
      property :title
      property :mappings
      property :settings
      property :created_at
      property :updated_at
  end
end