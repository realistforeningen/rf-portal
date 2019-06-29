module Models
  class Ledger < Sequel::Model
    one_to_many :vouchers
    many_to_one :eaccounting_integration

    def scheduled?
      if scheduled_at
        if synchronized_at
          scheduled_at > synchronized_at
        else
          true
        end
      else
        false
      end
    end
  end
end