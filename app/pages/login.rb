module Pages
  class Login
    def initialize(form)
      @form = form
    end

    def to_tubby
      Tubby.new { |t|
        t.div(class: "box") {
          t.div(class: "box-header") {
            t << "Login"
          }

          t.csrf_form(method: "post") {
            t.div(class: "box-body") {
              t.div(@form, class: "measure")
            }

            t.div(class: "box-action") {
              t.button("Sign in", class: "control-button")
            }
          }
        }
      }
    end
  end
end