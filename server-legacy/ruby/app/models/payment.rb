class Payment < ActiveRecord::Base

  def self.create_with_reference(payment_fields)
    random_offset = rand(-10..10)
    amount = payment_fields[:amount].to_i

    reference = rand(36**5).to_s(9)
    amount_received = amount + random_offset

    Payment.create(
      payment_fields.merge(
        {
          reference: reference,
          amount_received: amount_received
        }
      )
    )
  end

  def sanitized_attributes
    attributes.reject{|k| k == 'id'}
  end
end
