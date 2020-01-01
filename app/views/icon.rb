module Views
  class Icon
    def initialize(name)
      @name = name
    end

    def to_tubby
      Tubby.new { |t|
        t.svg(class: "icon") {
          t.tag!("use", "xlink:href": "#{RFP.webpack_path("zondicons.svg")}##{@name}")
        }
      }
    end
  end
end