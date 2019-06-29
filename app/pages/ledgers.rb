module Pages
  class Ledgers
    def ledgers
      @ledgers ||= Models::Ledger.order(:year).all
    end

    def to_tubby
      Tubby.new { |t|
        t.div(class: "page") {
          t.h2("All ledgers")

          t.table(class: "tbl") {
            t.thead {
              t.tr {
                t.th("Year")
                t.th("Integration")
                t.th("Synchronized at")
                t.th
              }
            }
            t.tbody {
              ledgers.each do |ledger|
                t.tr {
                  t.td(ledger.year)
                  t.td {
                    t << ledger.eaccounting_integration.name
                    t << " - "
                    t << ledger.eaccounting_integration.environment
                  }
                  t.td {
                    t << ledger.synchronized_at
                  }
                  t.td {
                    if ledger.scheduled?
                      t << "Synchronizing..."
                    else
                      t.csrf_form(method: 'post', action: "/ledgers/#{ledger.id}/sync") {
                        t.button("Synchronize", class: "control-button")
                      }
                    end
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
