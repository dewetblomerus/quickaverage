defmodule QuickAverage.BooleanTest do
  use ExUnit.Case, async: true
  alias QuickAverage.Boolean

  @fixtures [
    {"false", false},
    {"true", true},
    {true, true},
    {false, false}
  ]

  describe("parse/1") do
    test "parses the boolean" do
      Enum.each(@fixtures, fn {input, expected} ->
        assert Boolean.parse(input) == expected
      end)
    end
  end
end
