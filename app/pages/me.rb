module Pages
  class Me
    attr_reader :form

    def initialize
      @form = Forms::User[password: :optional].new(Web::ROOT_KEY)
    end

    def to_tubby
      Tubby.new { |t|
        t.div(class: "box") {
          t.div("Your profile", class: "box-header")

          t.csrf_form(method: "post") {
            t.div(class: "box-body measure") {
              t << @form
            }

            t.div(class: "box-action") {
              t.button("Save", class: "control-button")
            }
          }
        }
      }
    end
  end
end