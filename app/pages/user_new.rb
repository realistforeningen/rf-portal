module Pages
  class UserNew
    attr_reader :form

    def initialize
      @form = Forms::User[password: :required].new(Web::ROOT_KEY)
    end


    def to_tubby
      Tubby.new { |t|
        t.div(class: "box") {
          t.h2("New user", class: "box-header")

          t.csrf_form(method: "post") {
            t.div(class: "box-body") {
              t.div(@form, class: "measure")
            }
            
            t.div(class: "box-action") {
              t.button("Create", class: "control-button")
            }
          }
        }
      }
    end
  end
end