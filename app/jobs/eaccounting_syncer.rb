module Jobs
  class EaccountingSyncer < Que::Job
    self.maximum_retry_count = 0

    def run(integration_id, year)
      RFP.db.transaction do
        intgration = Models::EaccountingIntegration[integration_id]
        syncer = Eaccounting::Syncer.new(intgration, year)
        syncer.apply
        destroy
      end
    end
  end
end
