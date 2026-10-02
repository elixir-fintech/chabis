Code.require_file("test_helper.exs", __DIR__)

defmodule Chabis.FeatureImportTest do
  use ExUnit.Case

  describe "Features can import steps from other features" do
    test "can import empty steps" do
      defmodule FeatureImportableTest do
        use Chabis.Feature
      end

      defmodule FeatureImporterTest do
        use Chabis.Feature, file: "simplest.feature"
        import_steps(FeatureImportableTest)

        defthen ~r/^I provide Then$/, _vars, _state do
        end
      end

      {result, _output} = ChabisTestHelper.run()
      assert result == %{failures: 0, skipped: 0, total: 1, excluded: 0}
    end

    test "can import all steps" do
      defmodule FeatureImportableTest2 do
        use Chabis.Feature

        defthen ~r/^I provide Then$/, _vars, _state do
        end
      end

      defmodule FeatureImporterTest2 do
        use Chabis.Feature, file: "simplest.feature"
        import_steps(FeatureImportableTest2)
      end

      {result, _output} = ChabisTestHelper.run()
      assert result == %{failures: 0, skipped: 0, total: 1, excluded: 0}
    end

    test "can work together with imported steps" do
      defmodule FeatureImportableTest3 do
        use Chabis.Feature

        defgiven ~r/^I provide Given$/, _vars, %{state: state} do
          {:ok, %{state: state + 1}}
        end

        defgiven ~r/^I provide And$/, _vars, %{state: state} do
          {:ok, %{state: state + 1}}
        end
      end

      defmodule FeatureImporterTest3 do
        use Chabis.Feature, file: "simple.feature"
        import_steps(FeatureImportableTest3)

        setup do
          {:ok, %{state: 0}}
        end

        defwhen ~r/^I provide When$/, _vars, %{state: state} do
          {:ok, %{state: state + 1}}
        end

        defthen ~r/^I provide Then$/, _vars, %{state: state} do
          assert state == 3
        end
      end

      {result, _output} = ChabisTestHelper.run()
      assert result == %{failures: 0, skipped: 0, total: 1, excluded: 0}
    end
  end

  describe "Features can import tags from other features" do
    test "can import empty tags" do
      defmodule FeatureImportableTest4 do
        use Chabis.Feature
      end

      defmodule FeatureImporterTest4 do
        use Chabis.Feature, file: "simplest.feature"
        import_tags(FeatureImportableTest4)

        defthen ~r/^I provide Then$/, _vars, _state do
        end
      end

      {result, _output} = ChabisTestHelper.run()
      assert result == %{failures: 0, skipped: 0, total: 1, excluded: 0}
    end

    test "can import provided tags" do
      defmodule FeatureImportableTest5 do
        use Chabis.Feature

        tag @module_tag do
          {:ok, %{module_state: "state"}}
        end
      end

      defmodule FeatureImporterTest5 do
        use Chabis.Feature, file: "simplest.feature"
        @moduletag :module_tag
        import_tags(FeatureImportableTest5)

        defthen ~r/^I provide Then$/, _vars, state do
          assert state.module_state == "state"
        end
      end

      {result, _output} = ChabisTestHelper.run()
      assert result == %{failures: 0, skipped: 0, total: 1, excluded: 0}
    end
  end

  describe "Features can import whole features" do
    test "can import whole features" do
      defmodule FeatureImportableTest6 do
        use Chabis.Feature

        tag @module_tag do
          {:ok, %{state: 10}}
        end

        defgiven ~r/^I provide Given$/, _vars, %{state: state} do
          {:ok, %{state: state + 1}}
        end

        defgiven ~r/^I provide And$/, _vars, %{state: state} do
          {:ok, %{state: state + 1}}
        end
      end

      defmodule FeatureImporterTest6 do
        use Chabis.Feature, file: "simple.feature"
        import_feature(FeatureImportableTest6)
        @moduletag :module_tag

        defwhen ~r/^I provide When$/, _vars, %{state: state} do
          {:ok, %{state: state + 1}}
        end

        defthen ~r/^I provide Then$/, _vars, %{state: state} do
          assert state == 13
        end
      end

      {result, _output} = ChabisTestHelper.run()
      assert result == %{failures: 0, skipped: 0, total: 1, excluded: 0}
    end
  end

  describe "Features cannot import from invalid modules" do
    test "import_steps raises a helpful error for modules that are not compiled" do
      assert_raise ArgumentError, ~r/cannot import steps from ThisModuleDoesNotExist/, fn ->
        defmodule FeatureImporterMissingModuleTest do
          use Chabis.Feature, file: "simplest.feature"
          import_steps(ThisModuleDoesNotExist)
        end
      end
    end

    test "import_steps raises a helpful error for modules that do not use Chabis.Feature" do
      assert_raise ArgumentError, ~r/does not `use Chabis\.Feature`/, fn ->
        defmodule FeatureImporterNotChabisStepsTest do
          use Chabis.Feature, file: "simplest.feature"
          import_steps(String)
        end
      end
    end

    test "import_tags raises a helpful error for modules that are not compiled" do
      assert_raise ArgumentError, ~r/cannot import tags from ThisModuleDoesNotExist/, fn ->
        defmodule FeatureImporterMissingTagsTest do
          use Chabis.Feature, file: "simplest.feature"
          import_tags(ThisModuleDoesNotExist)
        end
      end
    end

    test "import_tags raises a helpful error for modules that do not use Chabis.Feature" do
      assert_raise ArgumentError, ~r/does not `use Chabis\.Feature`/, fn ->
        defmodule FeatureImporterNotChabisTagsTest do
          use Chabis.Feature, file: "simplest.feature"
          import_tags(String)
        end
      end
    end
  end
end
