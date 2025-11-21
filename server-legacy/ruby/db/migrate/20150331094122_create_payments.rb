class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.string "reference", null: false
      t.integer "amount"
      t.integer "amount_received"
      t.string "country_from"
      t.string "sender_full_name"
      t.string "sender_address"
      t.string "school"
      t.string "currency_from"
      t.integer "student_id"
      t.string "email"
    end
  end
end
