module Pages
  class LedgerSync
    def initialize(ledger)
      @ledger = ledger
    end

    def to_tubby
      Tubby.new { |t|
        t << Views::LedgerContext.new(@ledger)

        t.div(class: "box") {
          t.div("Synchronize", class: "box-header")
          t.div(class: "box-body") {

            t.p(class: "measure") {
              t << "The ledger is automatically synchronized every night. "
              t << "You can manually schedule a synchronization now if needed. "
              t << "The data is synchronized in the background and will be available as soon as possible. "
            }
          }

          t.div(class: "box-action") {
            t.csrf_form(method: "post") {
              t.button("Submit synchronization", class: "control-button")
            }
          }
        }
      }
    end
  end
end