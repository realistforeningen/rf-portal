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
        t.label(class: "control-section") {
          t.label {
            t.div("Name", class: "control-label")
            t.input(type: "name", name: name.key, value: name.value, class: "control-input")
          }
        }

        t.label(class: "control-section") {
          t.div("Email", class: "control-label")
          t.input(type: "email", name: email.key, value: email.value, class: "control-input")
        }
      }
    end
  end
end