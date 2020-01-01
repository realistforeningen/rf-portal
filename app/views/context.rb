module Views
  class Context
    Action = Struct.new(:title, :url)

    def actions
      nil
    end

    def to_tubby
      Tubby.new { |t|
        t.div(class: "box") {
          t.div(class: "px-8 py-2") {
            t.div(context_title, class: "text-gray-600 font-semibold text-sm")
            t.div(class: "flex items-baseline") {
              t.a(href: url) {
                t.div(title, class: "text-2xl hover:underline")
              }
            }
          }

          if actions = self.actions
            t.div(class: "box-action small text-gray-700 flex") {
              actions.each do |action|
                t.a(action.title, class: "mr-6 border-b border-blue-500 leading-none hover:text-black", href: action.url)
              end

            }
          end
        }
      }
    end
  end
end