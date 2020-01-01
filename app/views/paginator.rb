module Views
  class Paginator
    def initialize(paginator, query_params = nil)
      @paginator = paginator
      @query_params = query_params
    end

    def to_tubby
      Tubby.new { |t|
        t.div(class: "box-body") {
          t.div(class: "flex items-center") {
            pagination_link(t, icon: "cheveron-left", page: @paginator.prev_page)
            t.div("Page #{@paginator.current_page} of #{@paginator.last_page}", class: "mx-2 text-sm")
            pagination_link(t, icon: "cheveron-right", page: @paginator.next_page)
          }
        }
      }
    end

    def pagination_link(t, icon:, page: nil)
      if page
        href = "?page=#{page}&#{@query_params}"
        klass = "text-indigo-800"
      else
        klass = "text-gray-400"
      end

      t.div(class: "leading-none #{klass} text-xl") {
        t.a(href: href) {
          t << Views::Icon.new(icon)
        }
      }
    end
  end
end