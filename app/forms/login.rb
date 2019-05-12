module Forms
  class Login < DelegateForm
    FIND_USER = V.transform(message: "No user exists with the given email") { |params|
      user = Models::User.first(email: params[:email])
      if user.nil?
        StepError
      else
        params[:user] = user
        params
      end
    }

    CHECK_PASSWORD = V.validate(message: "Incorrect password") { |params|
      params[:user].matches_password?(params[:password])
    }

    def initialize
      field :email, Text.new
      field :password, Text.new

      self.schema = FIND_USER | CHECK_PASSWORD
    end

    def to_tubby
      email = self[:email]
      password = self[:password]

      Tubby.new { |t|
        if error?
          step, path = result.step_errors[0]
          t.div(class: "my-4 bg-red-100 border border-red-400 text-red-700 px-3 py-2 rounded") {
            t.strong("Oops: ", class: "font-bold")
            t << step.message
          }
        end

        t.label(class: "control-section") {
          t.div("Email", class: "control-label")
          t.input(type: "email", name: email.key, value: email.value, class: "control-input")
        }

        t.label(class: "control-section") {
          t.label {
            t.div("Password", class: "control-label")
            t.input(type: "password", name: password.key, class: "control-input")
          }
        }
      }
    end
  end
end