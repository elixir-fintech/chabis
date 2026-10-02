defmodule Chabis do
  @moduledoc """
  Story BDD tool for executing Gherkin `.feature` files as ExUnit tests.

  A fork of [cabbage-ex/cabbage](https://github.com/cabbage-ex/cabbage) in which the
  `Cabbage.*` modules are renamed to `Chabis.*`. See `Chabis.Feature` for usage.
  """
  def base_path(), do: Application.get_env(:chabis, :features, "test/features/")
  def global_tags(), do: Application.get_env(:chabis, :global_tags, []) |> List.wrap()
end
