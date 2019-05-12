module Pages
  class Error
    def to_tubby
      Tubby.new { |t|
        t.div(class: "page") {
          t.h2("Something went wrong! 💩")

          t << "Oops. This was embarrassing. The error has been reported and will be dealt with. "
        }
      }
    end
  end
end