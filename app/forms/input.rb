module Forms
  class Input
    def initialize(field:, name:, type: "text")
      @field = field
      @name = name
      @type = type
      @value = type == "password" ? "" : field.value
    end

    def to_tubby
      Tubby.new { |t|
        t.label(class: "control-section") {
          t.label {
            t.div(@name, class: "control-label")
            t.input(type: @type, name: @field.key, value: @value, class: "control-input #{'error' if @field.error?}")
          }
        }
      }
    end
  end
end