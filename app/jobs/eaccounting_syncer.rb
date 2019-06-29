module Jobs
  class EaccountingSyncer < Que::Job
    self.maximum_retry_count = 0

    def run(ledger_id)
      RFP.db.transaction do
        ledger = Models::Ledger[ledger_id]
        syncer = Eaccounting::Syncer.new(ledger)
        syncer.apply
        destroy
      end
    end
  end
end
