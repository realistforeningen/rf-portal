module Pages
  class Error
    def to_tubby
      Tubby.new { |t|
        t.div(class: "box") {
          t.div("Something went wrong! 💩", class: "box-header")

          t.div("Oops. This was embarrassing. The error has been reported and will be dealt with. ", class: "box-body")
        }
      }
    end
  end
end