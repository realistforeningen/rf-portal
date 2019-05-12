module Views
  class Navigation
    class Section
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

    Link = Struct.new(:name, :url) do
      def to_tubby
        Tubby.new { |t|
          t.a(name, href: url, class: "underline hover:no-underline")
        }
      end
    end

    Button = Struct.new(:name, :url) do
      def to_tubby
        Tubby.new { |t|
          t.csrf_form(method: :post, action: url) {
            t.button(name, class: "underline hover:no-underline")
          }
        }
      end
    end

    def initialize(user)
      @user = user
    end

    def to_tubby
      Tubby.new { |t|
        t << Section.new("Users") { |s|
          s << Link.new("All users", "/users")
          s << Link.new("New user", "/users/new")
        }

        t << Section.new(@user.name) { |s|
          s << Link.new("Settings", "/user")
          s << Button.new("Sign out", "/logout")
        }
      }
    end
  end
end