module Forms
  class User < Group
    Parametric.make(self) do |options|
      field(:name, Text)
      field(:email, Text)
      field(:password, PasswordConfirm) if options[:password]

      validate do
        fields = {
          name: field(:name) | trim | required,
          email: field(:email) | trim | required | match(/^\S+@\S+$/, message: "This does not look like an email"),
        }
        fields[:password] = field(:password) if options[:password]
        fields[:password] |= required if options[:password] == :required
        form(fields)
      end
    end


    USED_EMAIL = Ippon::Validate::Builder.validate(message: "Email is already used") { false }

    def mark_used_email
      USED_EMAIL.process(email.validate)
    end

    def from_model(user)
      name.value = user.name
      email.value = user.email
    end

    def to_tubby
      Tubby.new { |t|
        t << Input.new(field: name, label: "Name")
        t << Input.new(field: email, label: "Email", type: "email")
        t << password if respond_to?(:password)
      }
    end
  end
end