module Views
  class Layout
    attr_accessor :title, :content
    attr_reader :head_contents

    def initialize
      @head_contents = []
    end

    def to_tubby
      Tubby.new  { |t|
        t.doctype!
        t.html {
          t.head {
            t.title {
              if title
                t << title << " - RF-portal"
              else
                t << "RF-portal"
              end
            }

            @head_contents.each { |c| t << c }
          }
        }

        t.body {
          t.div(class: "py-2 px-4 flex items-baseline border-b bg-gray-200") {
            t.a("RF-portal", href: "/", class: "mr-2 text-xl font-semibold hover:underline")
          }

          t.div(class: "py-2 px-4") {
            t << @content
          }
        }
      }
    end
  end
end