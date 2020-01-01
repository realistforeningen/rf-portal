module Pages
  class Eaccounting
    def integrations
      @integrations ||= Models::EaccountingIntegration.all
    end

    def to_tubby
      Tubby.new { |t|
        t.div(class: "box") {
          t.div("All eAccounting integrations", class: "box-header")

          t.table(class: "box-tbl") {
            t.thead {
              t.tr {
                t.th("Name")
                t.th("Environment")
              }
            }
            t.tbody {
              integrations.each do |i|
                t.tr {
                  t.td(i.name, class: "main")
                  t.td(i.environment)
                }
              end
            }
          }
        }

        t.div(class: "box") {
          t.div("Connect new account", class: "box-header")

          t.div(class: "box-action") {
            RFP.eaccounting_clients.each_key do |name|
              t.a("Connect to #{name}", href: "/eaccounting/authorize/#{name}", class: "control-button")
            end
          }
        }
      }
    end
  end
end