defmodule QuickAverage.Boolean do
  def parse("false"), do: false
  def parse("true"), do: true
  def parse(input), do: !!input
end
