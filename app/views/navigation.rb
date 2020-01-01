module Views
  class Navigation
    class OldSection
      def initialize(name)
        @name = name
        @items = []
        yield self if block_given?
      end

      def <<(item)
        @items << item
      end

      def to_tubby
        return if @items.empty?

        Tubby.new { |t|
          t.div(class: "text-sm border-l border-gray-500 pl-6 ml-6") {
            t.div(@name, class: "font-bold text-gray-800")
            @items.each do |item|
              t.div(item)
            end
          }
        }
      end
    end

    TEXT_STYLE = "border-b border-blue-500 text-gray-800 hover:text-black hover:font-semibold" #"underline hover:no-underline text-blue-600"

    Link = Struct.new(:name, :url) do
      def to_tubby
        Tubby.new { |t|
          t.div {
            t.a(name, href: url, class: TEXT_STYLE)
          }
        }
      end
    end

    Button = Struct.new(:name, :url) do
      def to_tubby
        Tubby.new { |t|
          t.csrf_form(method: :post, action: url, class: "block") {
            t.button(name, class: TEXT_STYLE)
          }
        }
      end
    end

    class Section
      def initialize(title:, icon:, &blk)
        @title = title
        @icon = icon
        @blk = blk
      end

      def to_tubby
        Tubby.new { |t|
          t.div(class: "flex-1 flex mr-16 mb-4") {
            t.div(class: "text-xl mr-2 text-gray-700") {
              t << Icon.new(@icon)
            }

            t.div {
              t.h2(@title, class: "text-xl font-semibold")

              @blk.call(t)
            }
          }
        }
      end
    end

    def initialize(user)
      @user = user
    end

    def to_tubby
      Tubby.new { |t|
        t.div(class: "flex flex-wrap my-4") {
          t << Section.new(title: "Users", icon: "user-group") { |t|
            t << Link.new("All users", "/users")
            t << Link.new("New user", "/users/new")
          }
  
          t << Section.new(title: "Accounting", icon: "box") { |s|
            s << Link.new("Ledgers", "/ledgers")
            s << Link.new("eAccounting", "/eaccounting")
          }
  
          t << Section.new(title: @user.name, icon: "user") { |s|
            s << Link.new("Your profile", "/me")
            s << Button.new("Sign out", "/logout")
          }
        }
      }
    end
  end
end