print 'Seeding... '

def create_payment(currency: )
  Payment.create_with_reference(amount: rand(36**5).to_s(9), country_from: Faker::StarWars.planet, sender_full_name: Faker::StarWars.character, sender_address: Faker::Address.street_address, school: Faker::University.name, currency_from: currency, student_id: Faker::Number.number(6), email: Faker::Internet.email)
end

2.times { create_payment(currency: 'CAD') }
2.times { create_payment(currency: 'EUR') }
2.times { create_payment(currency: 'USD') }

puts 'DONE'
