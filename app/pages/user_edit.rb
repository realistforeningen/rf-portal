module Pages
  class UserEdit
    attr_reader :form

    def initialize(user)
      @user = user
      @form = Forms::User.new
      @form.key = Web::ROOT_KEY
    end

    def to_tubby
      Tubby.new { |t|
        t.div(class: "page") {
          t.h2("Editing: #{@user.name}")

          t.csrf_form(method: "post", class: "measure") {
            t << @form

            t.button("Save", class: "control-button")
          }
        }
      }
    end
  end
end