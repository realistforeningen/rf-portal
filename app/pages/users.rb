module Pages
  class Users
    def users
      @users ||= Models::User.order(:name).all
    end

    def to_tubby
      Tubby.new { |t|
        t.div(class: "page") {
          t.h2("All users")
  
          t.table(class: "tbl") {
            t.thead {
              t.tr {
                t.th("Name")
                t.th("Email")
                t.th
              }
            }
            t.tbody {
              users.each do |user|
                t.tr {
                  t.td(user.name)
                  t.td(user.email)
                  t.td {
                    t.a("Edit", href: "/users/#{user.id}/edit", class: "link")
                  }
                }
              end
            }
          }
        }
      }
    end
  end
end
