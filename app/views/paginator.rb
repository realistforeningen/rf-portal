module Views
  class Paginator
    def initialize(paginator, query_params = nil)
      @paginator = paginator
      @query_params = query_params
    end

    def to_tubby
      Tubby.new { |t|
        t << "Page #{@paginator.current_page} of #{@paginator.last_page}"
        pagination_link(t, "Prev", @paginator.prev_page)
        pagination_link(t, "Next", @paginator.next_page)
      }
    end

    def pagination_link(t, text, page = nil)
      href = "?page=#{page}&#{@query_params}" if page
      t.a(text, href: href, class: "ml-2 px-2 border rounded #{'link' if href}")
    end
  end
end