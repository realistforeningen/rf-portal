module Forms
  class PasswordConfirm < DelegateForm
    def initialize
      field :password, Text.new do |f|
        f.schema = V.trim
      end

      field :password_confirm, Text.new do |f|
        f.schema = V.trim
      end

      self.schema = V.validate(message: "Passwords must match") { |data|
        if data[:password]
          data[:password] == data[:password_confirm]
        else
          true
        end
      } | V.transform { |data|
        if data[:password]
          data[:password]
        else
          nil
        end
      }
    end

    def mark_required
      self.schema |= V.required(message: "Password is required")
    end
    
    def to_tubby
      Tubby.new { |t|
        t << Input.new(field: self[:password], name: "Password", type: "password")
        t << Input.new(field: self[:password_confirm], name: "Confirm password", type: "password")

        if error?
          step, path = result.step_errors[0]
          t.div(class: "my-4 bg-red-100 border border-red-400 text-red-700 px-3 py-2 rounded") {
            t.strong("Oops: ", class: "font-bold")
            t << step.message
          }
        end
      }
    end
  end
end