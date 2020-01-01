module Forms
  class Login < Group
    field(:email, Text)
    field(:password, Text)

    validate do
      form(
        email: field(:email) | trim | required,
        password: field(:password) | trim | required,
      ) |
      transform(message: "No user exists with the given email") { |params|
        user = Models::User.first(email: params[:email])
        if user.nil?
          StepError
        else
          params[:user] = user
          params
        end
      } |
      validate(message: "Incorrect password") { |params|
        params[:user].matches_password?(params[:password])
      }
    end

    def to_tubby
      Tubby.new { |t|
        if step = errors.steps[0]
          t.div(class: "my-4 bg-red-100 border border-red-400 text-red-700 px-3 py-2 rounded") {
            t.strong("Oops: ", class: "font-bold")
            t << step.message
          }
        end

        t << Input.new(field: email, label: "Email", type: "email")
        t << Input.new(field: password, label: "Password", type: "password")
      }
    end
  end
end