module Forms
  class Input
    def initialize(field:, label:, type: "text", error: nil)
      @name = field.key.to_s
      @label = label
      @type = type
      @value = type == "password" ? "" : field.value
      @error = error || field.errors
    end

    def to_tubby
      err = error_message

      Tubby.new { |t|
        t.label(class: "control-section") {
          t.label {
            t.div(@label, class: "control-label")
            t.input(type: @type, name: @name, value: @value, class: "control-input #{'error' if err}")
            t.div(err, class: "text-red-600 pt-2") if err
          }
        }
      }
    end

    def error_message
      return @error if @error.is_a?(String)

      step = @error.steps[0]
      return if !step

      case step.type
      when :required
        "This field is required"
      else
        step.message
      end
    end
  end
end