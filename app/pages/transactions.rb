require 'ippon/paginator'
require 'uri'

module Pages
  class Transactions
    PER_PAGE = 50
    attr_reader :form

    def initialize(ledger)
      @ledger = ledger
      @form = Forms::TransactionFilter.new
      @form.key = Web::ROOT_KEY
    end

    def query_params
      @query_params ||= URI.encode_www_form(www_form)
    end

    def www_form
      result = []
      @form.each_pair do |name, value|
        next if name == "page"
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
        t.div(class: "page") {
          t.h2("Transactions")

          t.div(class: "page-section-header") {
            t.h3("Filters", class: "title")
          }

          t.div(class: "page-section-body") {
            t.form(method: "get", class: "measure") {
              t << @form
              t.button("Apply filter", class: "control-button")
            }
          }

          t.div(class: "page-section-header") {
            t.div(class: "flex") {
              t.h3("Results", class: "title")
              t.div(class: "flex-1")
              if @paginator
                t.div(class: "text-sm") {
                  t << Views::Paginator.new(@paginator, query_params)
                }
              end
            }
          }

          t.div(class: "page-section-body") {
            if @filter_result.valid?
              table(t)
            else
              t << "Nope!"
            end
          }
        }
      }
    end

    def table(t)
      t.table(class: "tbl") {
        t.thead {
          t.tr {
            t.th("Voucher")
            t.th("Dato")
            t.th("Account")
            t.th("Comment")
          }
        }

        t.tbody {
          @transactions.each do |trans|
            t.tr {
              t.td {
                t.a(trans.voucher.number, href: "/ledgers/#{@ledger.id}/vouchers/#{trans.voucher.id}", class: "link")
              }
              t.td(trans.voucher.date, class: "whitespace-no-wrap")
              t.td(trans.account)
              t.td(trans.comment || trans.voucher.comment)
            }
          end

        }
      }
    end
  end
end