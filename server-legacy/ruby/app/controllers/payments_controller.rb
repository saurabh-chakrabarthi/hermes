require 'json'

class PaymentsController < ApplicationController
  get '/payment' do
    send_file('./app/views/booking.html')
  end

  post '/payment' do
    Payment.create_with_reference(params)
    send_file('./app/views/confirmation.html')
  end
end
