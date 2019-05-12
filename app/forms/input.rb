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

            if msg = error_message
              t.div(msg, class: "text-red-600 pt-2")
            end
          }
        }
      }
    end

    def error_message
      return if !@field.error?
      step, path = @field.result.step_errors[0]
      case step.type
      when :required
        "This field is required"
      else
        step.message
      end
    end
  end
end