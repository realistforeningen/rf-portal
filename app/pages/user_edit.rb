module Pages
  class UserEdit
    attr_reader :form

    def initialize(user)
      @user = user
      @form = Forms::User[].new(Web::ROOT_KEY)
    end

    def to_tubby
      Tubby.new { |t|
        t << Views::UserContext.new(@user)

        t.div(class: "box") {
          t.h2("Edit", class: "box-header")

          t.csrf_form(method: "post") {
            t.div(class: "box-body") {
              t.div(@form, class: "measure")
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