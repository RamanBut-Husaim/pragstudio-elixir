defmodule SurveyTest do
  use ExUnit.Case
  doctest Survey

  test "greets the world" do
    assert Survey.hello() == :world
  end
end
