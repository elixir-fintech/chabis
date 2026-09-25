defmodule Cabbage.Feature.ParameterTest do
  use ExUnit.Case, async: true

  alias Cabbage.Feature.Parameter

  describe "converting cucumber expression term to parameter" do
    test "term in the form of {name:type} returns a parameter" do
      term = "{name:int}"
      result = Parameter.convert(term)
      assert %Cabbage.Feature.Parameter{capture_name: capture_name, type_regex: type_regex} = result
      assert capture_name == "name"
      assert type_regex.source == ~r/\d+/.source
    end

    test "term not in the form of a parameter returns itself" do
      term = "coffee"
      result = Parameter.convert(term)
      assert result == "coffee"
    end
  end
end
