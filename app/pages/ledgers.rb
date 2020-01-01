module Pages
  class Ledgers
    def ledgers
      @ledgers ||= Models::Ledger.order(Sequel.desc(:year)).all
    end

    def to_tubby
      Tubby.new { |t|
        t.div(class: "box") {
          t.div("All ledgers", class: "box-header")

          t.table(class: "box-tbl") {
            t.thead {
              t.tr {
                t.th("Year")
                t.th("Integration")
                t.th("Last synchronized at")
              }
            }
            t.tbody {
              ledgers.each do |ledger|
                t.tr {
                  t.td(class: "main") {
                    t.a(ledger.year, href: "/ledgers/#{ledger.id}")
                  }
                  t.td {
                    t << ledger.eaccounting_integration.name
                    t << " - "
                    t << ledger.eaccounting_integration.environment
                  }
                  t.td {
                    t << ledger.synchronized_at
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
