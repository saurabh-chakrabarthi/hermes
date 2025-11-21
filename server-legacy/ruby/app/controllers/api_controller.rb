require 'json'
require 'models/payment'

class ApiController < ApplicationController
  before do
    content_type :json
  end

  get '/api' do
    JSON.dump('message' => 'Hello Developer')
  end

  get '/api/bookings' do
    bookings = Payment.all.map(&:sanitized_attributes)
    JSON.dump(bookings)
  end

  post '/api/bookings' do
    begin
      data = JSON.parse(request.body.read)
      payment = Payment.create_with_reference(data)
      status 201
      JSON.dump(payment.sanitized_attributes)
    rescue => e
      status 400
      JSON.dump('error' => e.message)
    end
  end
end
