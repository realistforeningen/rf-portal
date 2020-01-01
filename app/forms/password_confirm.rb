module Forms
  class PasswordConfirm < Group
    field(:password, Text)
    field(:password_confirm, Text)

    validate do
      form(
        password: field(:password) | trim,
        password_confirm: field(:password_confirm) | trim,
      ) |
      validate(message: "Passwords must match") { |data|
        if data[:password]
          data[:password] == data[:password_confirm]
        else
          true
        end
      } |
      transform { |data|
        if data[:password]
          data[:password]
        else
          nil
        end
      }
    end
    
    def to_tubby
      Tubby.new { |t|
        t << Input.new(field: password, label: "Password", type: "password", error: errors)
        t << Input.new(field: password_confirm, label: "Confirm password", type: "password")
      }
    end
  end
end