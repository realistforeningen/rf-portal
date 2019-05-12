module Forms
  class User < DelegateForm
    def initialize
      field :name, Text.new do |f|
        f.schema = V.trim | V.required
      end

      field :email, Text.new do |f|
        f.schema = V.trim | V.required
      end
    end

    def with_password
      field :password, Text.new do |f|
        f.schema = V.trim | V.required
      end
    end

    UNIQUE_EMAIL = V.validate(message: "Email is already used") { false }

    def email_unique
      self[:email].result.errors << Ippon::Validate::StepError.new(UNIQUE_EMAIL)
    end

    def from_model(user)
      from_hash(
        name: user.name,
        email: user.email,
      )
    end

    def to_tubby
      name = self[:name]
      email = self[:email]
      password = self[:password] if children.has_key?(:password)

      Tubby.new { |t|
        t << Input.new(field: name, name: "Name")
        t << Input.new(field: email, name: "Email", type: "email")
        t << Input.new(field: password, name: "Password", type: "password") if password
      }
    end
  end
end