module Views
  class Layout
    attr_accessor :title, :content, :navigation, :user
    attr_reader :head_contents
    attr_reader :header_contents

    def initialize
      @head_contents = []
      @header_contents = []
    end

    def to_tubby
      Tubby.new  { |t|
        t.doctype!
        t.html {
          t.head {
            t.meta(name: "viewport", content: "width=device-width, initial-scale=1")

            t.title {
              if title
                t << title << " - RF-portal"
              else
                t << "RF-portal"
              end
            }

            @head_contents.each { |c| t << c }
          }

          t.body {
            t.div(class: "backdrop")

            t.script <<~JS
              function Ra() { document.body.classList.add('nav-active') }
              function Rd() { document.body.classList.remove('nav-active') }
              function Rt() { document.body.classList.toggle('nav-active') }
            JS
  
            t.div(class: "layout-col") {
              t.div(class: "relative", onmouseleave: "Rd()") {
                t.div(class: "pt-4 pb-2 flex z-20 relative text-gray-800") {
                  t.a(href: "/", onmouseenter: @navigation && "Ra()", onclick: @navigation && "Rt();return false", class: "nav-indicator px-1") {
                    t << "RF-portal"

                    t.span(class: "pl-1") {
                      t << Icon.new("cheveron-down")
                    } if @navigation
                  }
                  t.div(class: "flex-1")
                  t.div {
                    # TODO: User information
                  }
                }
  
                t.div(class: "layout-nav z-10 bg-white shadow-2xl rounded overflow-hidden") {
                  t.div(class: "layout-nav-gap")
  
                  t.div(class: "pb-8 pt-4 px-8 bg-gray-100 border-t") {
                    t << @navigation
                  }
                } if @navigation
              }
            }
  
            t.div(class: "layout-col") {
              t << @content
            }
          }
        }
      }
    end
  end
end