Code.require_file("test_helper.exs", __DIR__)

defmodule Chabis.FeatureTagsTest do
  use ExUnit.Case

  describe "Runns scenarios bassed on tags" do
    test "runs all scenarios when no tag filter is provided" do
      defmodule FeatureTagsTest do
        use Chabis.Feature, file: "tags.feature"

        defwhen ~r/^I provide When$/, _vars, _state do
        end

        defthen ~r/^I provide Then$/, _vars, _state do
        end
      end

      Application.put_env(:chabis, :global_tags, :global_chabis_tag)

      defmodule FeatureTagsTestWithTags do
        use Chabis.Feature, file: "tags.feature"
        @moduletag :ex_unit_style_tag

        defwhen ~r/^I provide When$/, _vars, _state do
        end

        defthen ~r/^I provide Then$/, _vars, _state do
        end
      end

      modules = [FeatureTagsTest, FeatureTagsTestWithTags]

      # Empty because loaded
      {result, _output} = ChabisTestHelper.run()
      assert result == %{failures: 0, skipped: 0, total: 8, excluded: 0}

      {result, _output} = ChabisTestHelper.run([exclude: [:test], include: [:some_tag]], modules)
      assert result == %{failures: 0, skipped: 0, total: 8, excluded: 4}

      {result, _output} = ChabisTestHelper.run([exclude: [:test], include: [:another_tag]], modules)
      assert result == %{failures: 0, skipped: 0, total: 8, excluded: 6}

      {result, _output} = ChabisTestHelper.run([exclude: [:test], include: [tag_with_value: "my_value"]], modules)
      assert result == %{failures: 0, skipped: 0, total: 8, excluded: 6}

      {result, _output} = ChabisTestHelper.run([exclude: [:test], include: [:ex_unit_style_tag]], modules)
      assert result == %{failures: 0, skipped: 0, total: 8, excluded: 4}

      {result, _output} = ChabisTestHelper.run([exclude: [:test], include: [:global_chabis_tag]], modules)
      assert result == %{failures: 0, skipped: 0, total: 8, excluded: 4}
    end
  end
end
