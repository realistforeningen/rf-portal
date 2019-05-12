module Pages
  class Login
    def initialize(form)
      @form = form
    end

    def to_tubby
      Tubby.new { |t|
        t.form(class: "measure", method: "post") {
          t << @form

          t.button("Sign in", class: "control-button")
        }
      }
    end
  end
end