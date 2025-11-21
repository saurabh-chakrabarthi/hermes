require 'spec_helper'

describe Payment do
  it 'can be created with a unique reference' do
    a_payment = Payment.create_with_reference(amount: 1000_00)
    another_payment = Payment.create_with_reference(amount: 1000_00)

    expect(a_payment.reference).not_to eql(another_payment.reference)
  end
end
