module Models
  class Ledger < Sequel::Model
    one_to_many :vouchers
    many_to_one :eaccounting_integration
  end
end