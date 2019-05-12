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

        t << Input.new(field: email, name: "Email", type: "email")
        t << Input.new(field: password, name: "Password", type: "password")
      }
    end
  end
end