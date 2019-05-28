module Models
  class Transaction < Sequel::Model
    many_to_one :voucher
  end
end