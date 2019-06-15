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

    def get_all(endpoint, filter:, order_by:, next_page_filter:, &blk)
      last_row = nil

      while true
        query = {"$pagesize" => 1000, "$orderby" => order_by}
        filters = [filter]
        if last_row
          filters << next_page_filter.call(last_row)
        end
        if filters.any?
          query["$filter"] = filters.join(" and ")
        end
        response = @integration.token.get(endpoint, params: query).parsed
        response["Data"].each(&blk)

        if response["Meta"]["TotalNumberOfPages"] <= 1
          break
        end

        last_row = response["Data"].last
      end
    end

    VOUCHER_KEYS = %i|id year eaccounting_integration_id number date comment|
    TRANSACTION_KEYS = %i|id voucher_id position account amount comment|

    def fetch_vouches_series(series)
      get_all(
        "v2/Vouchers",
        filter: "year(VoucherDate) eq #{@year} and NumberSeries eq '#{series}'",
        order_by: "Number",
        next_page_filter: ->(row) { "Number gt #{row['NumberAndNumberSeries'][/\d+/]}" },
      ) do |voucher|
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
            ((row["DebitAmount"] - row["CreditAmount"]) * 100).round,
            row["TransactionText"],
          ]
        end
      end
    end

    def fetch_data
      @vouchers = []
      @transactions = []

      %w[D B K F A G H E J].each do |series|
        fetch_vouches_series(series)
      end

      puts "Fetched #{@vouchers.size} vouchers"
    end
  end
end