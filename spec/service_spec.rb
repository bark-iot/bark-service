require File.expand_path '../spec_helper.rb', __FILE__

describe 'Barks Service' do
  before(:each) do
    DB.execute('TRUNCATE TABLE barks;')
    stub_request(:get, 'http://lb/users/by_token').
        with(headers: {'Authorization'=>"Bearer #{token}"}).
        to_return(status: 200, body: '{"id":1,"email":"test@test.com","token":"a722658b-0fea-415c-937f-1c1d3c8342fd","created_at":"2017-11-14 16:06:52 +0000","updated_at":"2017-11-14 16:06:52 +0000"}', headers: {})
    stub_request(:get, 'http://lb/users/by_token').
        with(headers: {'Authorization'=>'Bearer wrong_token'}).
        to_return(status: 422, body: '', headers: {})
    stub_request(:get, 'http://lb/houses/1').
        with(headers: {'Authorization'=>"Bearer #{token}"}).
        to_return(status: 200, body: '{"id":1,"user_id":1,"title":"Test","address":"Pr Pobedi 53b","key":"4d27328d-cbf6-493e-a5ec-7f6848ece614","created_at":"2017-11-24 20:32:29 +0000","updated_at":"2017-11-24 20:32:29 +0000"}', headers: {})
    stub_request(:get, 'http://lb/houses/2').
        with(headers: {'Authorization'=>'Bearer wrong_token'}).
        to_return(status: 200, body: '{"id":1,"user_id":2,"title":"Test","address":"Pr Pobedi 53b","key":"4d27328d-cbf6-493e-a5ec-7f6848ece614","created_at":"2017-11-24 20:32:29 +0000","updated_at":"2017-11-24 20:32:29 +0000"}', headers: {})
    stub_request(:get, 'http://lb/houses/3').
        with(headers: {'Authorization'=>'Bearer wrong_token'}).
        to_return(status: 404, body: '', headers: {})
    stub_request(:get, 'http://lb/houses/1/triggers/1/validate').
        with(headers: {'Authorization'=>"Bearer #{token}"}).
        to_return(status: 200, body: '{}', headers: {}) # actually returns trigger json
    stub_request(:get, 'http://lb/houses/1/actions/1/validate').
        with(headers: {'Authorization'=>"Bearer #{token}"}).
        to_return(status: 200, body: '{}', headers: {}) # actually returns action json
    stub_request(:get, 'http://lb/houses/1/triggers/2/validate').
        with(headers: {'Authorization'=>"Bearer #{token}"}).
        to_return(status: 404, body: '', headers: {})
    stub_request(:get, 'http://lb/houses/1/actions/2/validate').
        with(headers: {'Authorization'=>"Bearer #{token}"}).
        to_return(status: 404, body: '', headers: {})
  end

  #TODO: add delete house test

  it 'should show bark for house' do
    header 'Authorization', "Bearer #{token}"
    get "/houses/1/barks/#{bark.id}"

    expect(last_response).to be_ok
    body = JSON.parse(last_response.body)
    expect(body['title']).to eql('MyBark')
  end

  it 'should not show bark for another house' do
    d = Bark::Create.(title: 'MyBark', house_id: 2, trigger_id: 1, action_id: 1)['model']
    header 'Authorization', "Bearer #{token}"
    get "/houses/1/devices/#{d.id}"

    expect(last_response.status).to equal(404)
  end

  it 'should list all barks for house' do
    bark_title = bark.title
    header 'Authorization', "Bearer #{token}"
    get 'houses/1/barks'

    expect(last_response).to be_ok
    body = JSON.parse(last_response.body)
    expect(body[0]['title'] == bark_title).to be_truthy
  end

  it 'should not list barks for another house' do
    Bark::Create.(title: 'MyBark', house_id: 2, trigger_id: 1, action_id: 1)
    header 'Authorization', "Bearer #{token}"
    get '/houses/1/barks'

    expect(last_response).to be_ok
    body = JSON.parse(last_response.body)
    expect(body.size == 0).to be_truthy
  end

  it 'should not list all barks for user with wrong token' do
    header 'Authorization', 'Bearer wrong_token'
    get '/houses/1/barks'

    expect(last_response.status).to equal(401)
  end

  it 'should create bark for user' do
    header 'Authorization', "Bearer #{token}"
    post '/houses/1/barks', {title: 'MyBark', trigger_id: 1, action_id: 1, mappings: '{"input": "output"}', settings: '{"param": "value"}'}

    expect(last_response).to be_ok
    body = JSON.parse(last_response.body)
    expect(body['title']).to eql('MyBark')
    expect(body['trigger_id']).to eql(1)
    expect(body['house_id']).to eql(1)
    expect(body['action_id']).to eql(1)
    expect(body['mappings']).to eql('{"input": "output"}')
    expect(body['settings']).to eql('{"param": "value"}')
  end

  it 'should not create bark with invalid trigger and action' do
    header 'Authorization', "Bearer #{token}"
    post '/houses/1/barks', {title: 'MyBark', trigger_id: 2, action_id: 2, mappings: '{"input": "output"}', settings: '{"param": "value"}'}

    expect(last_response.status).to equal(422)
  end

  it 'should not create bark without required params' do
    header 'Authorization', "Bearer #{token}"
    post '/houses/1/barks'

    expect(last_response.status).to equal(422)
    body = JSON.parse(last_response.body)
    expect(body[0] == ['trigger_id', ['must be filled']]).to be_truthy
    expect(body[1] == ['action_id', ['must be filled']]).to be_truthy
    expect(body[2] == ['title', ['must be filled']]).to be_truthy
  end

  it 'should not create bark for user with wrong token' do
    header 'Authorization', 'Bearer wrong_token'
    post '/houses/1/barks', {title: 'MyBark', trigger_id: 1, action_id: 1}

    expect(last_response.status).to equal(401)
  end

  it 'should update bark for user' do
    header 'Authorization', "Bearer #{token}"
    put "/houses/1/barks/#{bark.id}", {title: 'My Bark'}

    expect(last_response).to be_ok
    body = JSON.parse(last_response.body)
    expect(body['title']).to eql('My Bark')
  end

  it 'should not update bark of another house' do
    another_bark = Bark::Create.(title: 'MyBark', house_id: 2, trigger_id: 1, action_id: 1)['model']
    header 'Authorization', "Bearer #{token}"
    put "/houses/1/barks/#{another_bark.id}", {title: 'My Bark'}

    expect(last_response.status).to equal(404)
  end

  it 'should not update bark without title' do
    header 'Authorization', "Bearer #{token}"
    put "/houses/1/barks/#{bark.id}", {title: '', mappings: '{"input": "output"}'}

    expect(last_response.status).to equal(422)
    body = JSON.parse(last_response.body)
    expect(body[0] == ['title', ['must be filled']]).to be_truthy
  end

  it 'should not update bark for user with wrong token' do
    header 'Authorization', 'Bearer wrong_token'
    put "/houses/1/barks/#{bark.id}", {title: 'MyBark'}

    expect(last_response.status).to equal(401)
  end

  it 'should delete bark for house' do
    bark_id = bark.id
    header 'Authorization', "Bearer #{token}"
    delete "/houses/1/barks/#{bark_id}"

    expect(last_response).to be_ok
    expect(Bark.where(id: bark_id).first == nil).to be_truthy
  end

  it 'should not delete bark of another house' do
    another_bark = Bark::Create.(title: 'MyBark', house_id: 2, trigger_id: 1, action_id: 1)['model']
    header 'Authorization', "Bearer #{token}"
    delete "/houses/1/barks/#{another_bark.id}"

    expect(last_response.status).to equal(404)
  end

  it 'should not delete bark for user with wrong token' do
    header 'Authorization', 'Bearer wrong_token'
    delete "/houses/1/barks/#{bark.id}"

    expect(last_response.status).to equal(401)
  end

  def token
    'a722658b-0fea-415c-937f-1c1d3c8342fd'
  end

  def bark
    Bark::Create.(title: 'MyBark', house_id: 1, trigger_id: 1, action_id: 1, mappings: '{"input": "output"}', settings: '{"param": "value"}', authorization_header: "Bearer #{token}")['model']
  end
end