defmodule QuickAverageWeb.AverageLive.StateTest do
  use ExUnit.Case, async: true
  alias QuickAverageWeb.AverageLive.State

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

  @users_waiting [
    %{
      name: "Darth",
      number: 6.0
    },
    %{
      name: "De Wet",
      number: nil
    }
  ]

  describe("list_users/1") do
    test "lists the users" do
      assert State.list_users(@presence_list) == @users_list
    end
  end

  describe("average/1") do
    test "lists the users" do
      assert State.average(@presence_list) == 8.33
    end
  end

  describe("show_numbers?/1") do
    test "reveal numbers if everyone submitted" do
      assert State.reveal_numbers?(@users_list) == true
    end

    test "hide numbers if we are waiting for numbers" do
      assert State.reveal_numbers?(@users_waiting) == false
    end
  end
end
