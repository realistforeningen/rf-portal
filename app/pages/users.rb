module Pages
  class Users
    def users
      @users ||= Models::User.order(:name).all
    end

    def to_tubby
      Tubby.new { |t|
        t.div(class: "box") {
          t.div(class: "box-header") {
            t << "All users"
          }

          t.table(class: "box-tbl") {
            t.thead {
              t.tr {
                t.th("Name")
                t.th("Email")
              }
            }
            t.tbody {
              users.each do |user|
                t.tr {
                  t.td(class: "main") {
                    t.a(user.name, href: "/users/#{user.id}/edit")
                  }
                  t.td(user.email)
                }
              end
            }
          }
        }
      }
    end
  end
end
