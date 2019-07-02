module Forms
  class TransactionFilter < DelegateForm
    def initialize
      field :page, Text.new do |f|
        f.schema = V.trim | V.optional | V.number
      end

      field :accounts, Text.new do |f|
        f.schema =
          V.transform { |s| s.strip.split(",") } |
          V.for_each(V.trim | V.required | V.number)
      end
    end

    def to_tubby
      accounts = self[:accounts]

      Tubby.new { |t|
        t << Input.new(field: accounts, name: "Accounts")
      }
    end
  end
end