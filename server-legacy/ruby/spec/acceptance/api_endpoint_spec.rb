require 'spec_helper'
require 'models/payment'

describe 'API Endpoint' do
  it 'responds with a JSON welcoming message' do
    get '/api'

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('{"message":"Hello Developer"}')
  end

  it 'returns all the stored payments' do
    Payment.all.map(&:delete)
    Payment.new(reference: 'any reference', amount: 10000).save

    get '/api/bookings'

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq("{\"bookings\":[{\"reference\":\"any reference\",\"amount\":10000,\"country_from\":null,\"sender_full_name\":null,\"sender_address\":null,\"school\":null,\"currency_from\":null,\"student_id\":null,\"email\":null}]}")
  end

  def app
    MyApplication::Dispatcher.new
  end
end
