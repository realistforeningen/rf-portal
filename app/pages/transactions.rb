require 'ippon/paginator'
require 'uri'

module Pages
  class Transactions
    PER_PAGE = 50
    attr_reader :form

    def initialize(ledger)
      @ledger = ledger
      @form = Forms::TransactionFilter.new(Web::ROOT_KEY)
    end

    def query_params
      @query_params ||= URI.encode_www_form(www_form)
    end

    def www_form
      result = []
      @form.serialize do |name, value|
        next if name == "page"
        next if value.nil?
        result << [name, value]
      end
      result
    end

    def load!
      @filter_result = @form.validate
      return if !@filter_result.valid?

      ledger_id = @ledger.id

      filter = @filter_result.value

      transactions = Models::Transaction
        .association_join(:voucher)
        .where { voucher[:ledger_id] =~ ledger_id }
        .order { voucher[:date] }

      if filter[:accounts].any?
        transactions = transactions.where(account: filter[:accounts])
      end

      total = transactions.count
      current_page = filter[:page] || 1
      @paginator = Ippon::Paginator.new(total, PER_PAGE, current_page)
      @transactions = transactions.limit(@paginator.limit, @paginator.offset).all
    end

    def to_tubby
      Tubby.new { |t|
        t << Views::LedgerContext.new(@ledger)
        
        t.div(class: "box") {
          t.div("Transactions", class: "box-header")

          t.div(class: "box-body") {
            t.form(method: "get", class: "measure") {
              t << @form
              t.button("Apply filter", class: "control-button")
            }
          }

          if @filter_result.valid?
            table(t)
          end
        }
      }
    end

    def table(t)
      t.table(class: "box-tbl") {
        t.thead {
          t.tr {
            t.th("Voucher")
            t.th("Date")
            t.th("Account", class: "right")
            t.th("Amount", class: "right")
            t.th("Comment")
          }
        }

        t.tbody {
          @transactions.each do |trans|
            t.tr {
              t.td(class: "main") {
                t.a(trans.voucher.number, href: "/ledgers/#{@ledger.id}/vouchers/#{trans.voucher.id}")
              }
              t.td(trans.voucher.date, class: "whitespace-no-wrap")
              t.td(trans.account, class: "right")
              t.td(Views::Money.new(trans.amount), class: "right")
              t.td(trans.comment || trans.voucher.comment)
            }
          end

        }
      }

      if @paginator
        t << Views::Paginator.new(@paginator, query_params)
      end
    end
  end
end