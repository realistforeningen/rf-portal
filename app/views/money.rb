module Views
  class Money
    def initialize(amount)
      @amount = amount
    end

    def to_tubby
      int, frac = @amount.abs.divmod(100)
      sign = @amount < 0 ? "-" : ""
      "kr %s%d.%02d" % [sign, int, frac]
    end
  end
end