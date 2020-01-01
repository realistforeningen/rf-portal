module Forms
  class TransactionFilter < Group
    field(:page, Text)
    field(:accounts, Text)

    validate do
      form(
        page: field(:page) | trim | optional | number,
        accounts: field(:accounts) |
          transform { |s| s ? s.strip.split(",") : [] } |
          for_each(trim | required | number)
      )
    end

    def to_tubby
      Tubby.new { |t|
        error = "Incorrect format" if accounts.error?
        t << Input.new(field: accounts, label: "Accounts", error: error)
      }
    end
  end
end