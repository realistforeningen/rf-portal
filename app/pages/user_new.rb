module Pages
  class UserNew
    attr_reader :form

    def initialize
      @form = Forms::User.new
      @form.with_password
      @form.key = Web::ROOT_KEY
    end

    def to_tubby
      Tubby.new { |t|
        t.div(class: "page") {
          t.h2("New user")

          t.form(method: "post", class: "measure") {
            t << @form

            t.button("Create", class: "control-button")
          }
        }
      }
    end
  end
end