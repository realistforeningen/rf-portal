module Models
  class Voucher < Sequel::Model
    one_to_many :transactions
    many_to_one :eaccounting_integration
  end
end