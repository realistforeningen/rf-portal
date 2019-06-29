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
                }
              end
            }
          }
        }
      }
    end
  end
end
