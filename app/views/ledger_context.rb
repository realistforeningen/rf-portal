module Views
    class LedgerContext < Context
      def initialize(ledger)
        @ledger = ledger
      end
  
      def context_title
        "Ledger"
      end
  
      def title
        @ledger.year
      end
  
      def url
        "/ledgers/#{@ledger.id}"
      end

      def actions
        [
          Action.new("Transactions", url),
          (Action.new("Synchronize", "#{url}/sync") if !@ledger.scheduled?),
        ].compact
      end
    end
  end