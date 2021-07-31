defmodule QuickAverageWeb.Presence.StateTest do
  use ExUnit.Case, async: true
  alias QuickAverageWeb.Presence.State

  @presence_list %{
    "phx-FpFUEe4C66uTTgHH" => %{
      metas: [
        %{
          name: "Darth",
          phx_ref: "FpFUFvXLJpz5pAOF",
          phx_ref_prev: "FpFUFl0T65P5pAeI"
        }
      ]
    },
    "phx-FpFUEgWEsnjpeAFB" => %{
      metas: [
        %{
          name: "Luke",
          phx_ref: "FpFUFZZeaaj5pASE",
          phx_ref_prev: "FpFUFWgobQ35pALH"
        }
      ]
    }
  }

  @create %{
    joins: %{
      "phx-FpbgrC9_I1gHTABJ" => %{
        metas: [%{name: "New User", phx_ref: "FpbgrC-wykgAIgAG"}]
      }
    },
    leaves: %{}
  }

  @update %{
    joins: %{
      "phx-FpFUEgWEsnjpeAFB" => %{
        metas: [
          %{
            name: "Luke Skywalker",
            phx_ref: "FpbgrDBQgQAAIgEC",
            phx_ref_prev: "FpbgrC-wykgAIgAG"
          }
        ]
      }
    },
    leaves: %{
      "phx-FpFUEgWEsnjpeAFB" => %{
        metas: [%{name: "Luke", phx_ref: "FpbgrC-wykgAIgAG"}]
      }
    }
  }

  @delete %{
    joins: %{},
    leaves: %{
      "phx-FpFUEgWEsnjpeAFB" => %{
        metas: [%{name: "Luke", phx_ref: "FpbgrC-wykgAIgAG"}]
      }
    }
  }

  @after_delete %{
    "phx-FpFUEe4C66uTTgHH" => %{
      metas: [
        %{
          name: "Darth",
          phx_ref: "FpFUFvXLJpz5pAOF",
          phx_ref_prev: "FpFUFl0T65P5pAeI"
        }
      ]
    }
  }

  describe("patch/2") do
    test "adds a new user" do
      assert State.patch(@presence_list, @create) ==
               Map.merge(@presence_list, @create.joins)
    end

    test "updates a user" do
      assert State.patch(@presence_list, @update) ==
               Map.merge(@presence_list, @update.joins)
    end

    test "deletes a user" do
      assert State.patch(@presence_list, @delete) ==
               @after_delete
    end
  end
end
