defmodule QuickAverageWeb.UsersTest do
  use ExUnit.Case, async: true
  alias QuickAverageWeb.Users

  @presence_list %{
    "phx-FpFUEe4C66uTTgHH" => %{
      metas: [
        %{
          name: "Darth",
          number: 6.0,
          phx_ref: "FpFUFvXLJpz5pAOF",
          phx_ref_prev: "FpFUFl0T65P5pAeI"
        }
      ]
    },
    "phx-FpFUEgWEsnjpeAFB" => %{
      metas: [
        %{
          name: "Luke",
          number: 10.0,
          phx_ref: "FpFUFZZeaaj5pASE",
          phx_ref_prev: "FpFUFWgobQ35pALH"
        }
      ]
    },
    "phx-FpFUEhHMdytRggOC" => %{
      metas: [
        %{
          name: "De Wet",
          number: 9.0,
          phx_ref: "FpFUFJ9yrlL5pAaD",
          phx_ref_prev: "FpFUFGgOMyb5pAZD"
        }
      ]
    }
  }

  @users_list [
    %{
      name: "Darth",
      number: 6.0,
      phx_ref: "FpFUFvXLJpz5pAOF",
      phx_ref_prev: "FpFUFl0T65P5pAeI"
    },
    %{
      name: "Luke",
      number: 10.0,
      phx_ref: "FpFUFZZeaaj5pASE",
      phx_ref_prev: "FpFUFWgobQ35pALH"
    },
    %{
      name: "De Wet",
      number: 9.0,
      phx_ref: "FpFUFJ9yrlL5pAaD",
      phx_ref_prev: "FpFUFGgOMyb5pAZD"
    }
  ]

  describe("list_users/1") do
    test "lists the users" do
      assert Users.list_users(@presence_list) == @users_list
    end
  end
end
