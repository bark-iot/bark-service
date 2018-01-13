require 'sinatra'
require 'sinatra/namespace'
require 'sinatra/reloader' if development?
require './config/logging.rb'
require './config/authorize.rb'
require './config/database.rb'
require './config/concepts.rb'
require './config/redis.rb'


set :bind, '0.0.0.0'
set :port, 80
set :public_folder, 'public'

get '/barks/docs' do
  redirect '/barks/docs/index.html'
end

namespace '/houses/:house_id' do
  get '/barks' do
    result = Bark::List.(house_id: params[:house_id])
    if result.success?
      body Bark::Representer.for_collection.new(result['models']).to_json
    else
      status 422
      body result['contract.default'].errors.messages.uniq.to_json
    end
  end

  post '/barks' do
    result = Bark::Create.(params)
    if result.success?
      body Bark::Representer.new(result['model']).to_json
    else
      if result['contract.default']
        status 422
        body result['contract.default'].errors.messages.uniq.to_json
      else
        status 404
      end
    end
  end

  get '/barks/:id' do
    result = Bark::Get.(params)
    if result.success?
      body Bark::Representer.new(result['model']).to_json
    else
      if result['contract.default']
        status 422
        body result['contract.default'].errors.messages.uniq.to_json
      else
        status 404
      end
    end
  end

  put '/barks/:id' do
    result = Bark::Update.(params)
    if result.success?
      body Bark::Representer.new(result['model']).to_json
    else
      if result['contract.default']
        status 422
        body result['contract.default'].errors.messages.uniq.to_json
      else
        status 404
      end
    end
  end

  delete '/barks/:id' do
    result = Bark::Delete.(params)
    if result.success?
      status 200
    else
      if result['contract.default'].errors.messages.size > 0
        status 422
        body result['contract.default'].errors.messages.uniq.to_json
      else
        status 404
      end
    end
  end
end