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

    def from_model(user)
      from_hash(
        name: user.name,
        email: user.email,
      )
    end

    def to_tubby
      name = self[:name]
      email = self[:email]

      Tubby.new { |t|
        t << Input.new(field: name, name: "Name")
        t << Input.new(field: email, name: "Email", type: "email")
      }
    end
  end
end