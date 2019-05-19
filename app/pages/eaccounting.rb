module Pages
  class Eaccounting
    def integrations
      @integrations ||= Models::EaccountingIntegration.all
    end

    def to_tubby
      Tubby.new { |t|
        t.div(class: "page") {
          t.h2("eAccounting")
          t.a("Connect to sandbox", href: "/eaccounting/sandbox", class: "control-button")

          t.table(class: "tbl") {
            t.thead {
              t.tr {
                t.th("Name")
                t.th("Environment")
              }
            }
            t.tbody {
              integrations.each do |i|
                t.tr {
                  t.td(i.name)
                  t.td(i.environment)
                }
              end
            }
          }
        }
      }
    end
  end
end