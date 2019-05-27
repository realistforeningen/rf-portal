module Pages
  class Eaccounting
    def integrations
      @integrations ||= Models::EaccountingIntegration.all
    end

    def to_tubby
      Tubby.new { |t|
        t.div(class: "page") {
          t.h2("eAccounting")

          RFP.eaccounting_clients.each_key do |name|
            t.a("Connect to #{name}", href: "/eaccounting/authorize/#{name}", class: "control-button")
          end

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