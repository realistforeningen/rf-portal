module Eaccounting
  class Syncer
    def initialize(integration, year)
      @integration = integration
      @year = year
    end

    def apply
      # Fetch data outside of the transactions
      fetch_data

      RFP.db.transaction do
        # Delete all existing data
        Models::Voucher.where(
          eaccounting_integration: @integration,
          year: @year
        ).delete

        Models::Voucher.import(VOUCHER_KEYS, @vouchers)
        Models::Transaction.import(TRANSACTION_KEYS, @transactions)
      end

      nil
    end

    private

    def get_all(endpoint, filter:, &blk)
      last_key = nil

      while true
        query = {"$pagesize" => 1000}
        filters = [filter]
        filters << "Id gt #{last_key.inspect}" if last_key
        if filters.any?
          query["$filter"] = filters.join(" and ")
        end
        response = @integration.token.get(endpoint, query).parsed
        response["Data"].each(&blk)

        if response["Meta"]["TotalNumberOfPages"] <= 1
          break
        end

        last_key = response["Data"].fetch("Id")
      end
    end

    VOUCHER_KEYS = %i|id year eaccounting_integration_id number date comment|
    TRANSACTION_KEYS = %i|id voucher_id position account amount comment|

    def fetch_data
      @vouchers = []
      @transactions = []

      get_all("v2/Vouchers", filter: "year(VoucherDate) eq '#{@year}'") do |voucher|
        @vouchers << [
          voucher["Id"],
          @year,
          @integration.id,
          voucher["NumberAndNumberSeries"],
          voucher["VoucherDate"],
          voucher["VoucherText"],
        ]

        voucher["Rows"].each_with_index do |row, idx|
          @transactions << [
            "#{voucher["Id"]}-#{idx}",
            voucher["Id"],
            idx,
            row["AccountNumber"],
            ((row["DebitAmount"] - row["CreditAmount"]) / 100).to_i,
            row["TransactionText"],
          ]
        end
      end

      puts "Fetched #{@vouchers.size} vouchers"
    end
  end
end