defmodule QuickAverageWeb.AverageLive.StateTest do
  use ExUnit.Case, async: true
  alias QuickAverageWeb.AverageLive.State

  @presence_list %{
    "phx-FpFUEe4C66uTTgHH" => %{
      metas: [
        %{
          only_viewing: false,
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
          only_viewing: false,
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
          only_viewing: false,
          name: "De Wet",
          number: 9.0,
          phx_ref: "FpFUFJ9yrlL5pAaD",
          phx_ref_prev: "FpFUFGgOMyb5pAZD"
        }
      ]
    },
    "phx-FqV4G7Id0zASHQLH" => %{
      metas: [
        %{
          only_viewing: true,
          name: "JP",
          number: 1000,
          phx_ref: "FqV4M4ciuqfljARF",
          phx_ref_prev: "FqV4My7TpITljAQF"
        }
      ]
    }
  }

  describe("average/1") do
    test "lists the users" do
      assert State.average(@presence_list) == 8.33
    end
  end

  describe("parse_number/1") do
    test "parse a number from a string" do
      assert State.parse_number("3") === 3
    end

    test "parse non numbers as nil" do
      assert State.parse_number("word") == nil
    end

    test "round floats with large decimals to 2 decimal points" do
      assert State.parse_number("7.777") == 7.78
    end

    test "limit large numbers to one million" do
      assert State.parse_number("999999999") == 1_000_000
    end

    test "limit large negative numbers to negative one million" do
      assert State.parse_number("-999999999") == -1_000_000
    end
  end

  describe("integerize/1") do
    test "floats remain as floats" do
      assert State.integerize(8.3) == 8.3
    end

    test "round floats become integers" do
      assert State.integerize(8.0) == 8
    end

    test "integers remain integers" do
      assert State.integerize(8) == 8
    end
  end

  @all_numbers_present %{
    "phx-FpFUEe4C66uTTgHH" => %{
      metas: [
        %{
          number: 6.0
        }
      ]
    },
    "phx-FpFUEgWEsnjpeAFB" => %{
      metas: [
        %{
          number: 10.0
        }
      ]
    },
    "phx-FqV4G7Id0zASHQLH" => %{
      metas: [
        %{
          only_viewing: true,
          name: "JP",
          number: nil,
          phx_ref: "FqV4M4ciuqfljARF",
          phx_ref_prev: "FqV4My7TpITljAQF"
        }
      ]
    }
  }

  describe("all_submitted?/1") do
    test "true when all numbers present" do
      assert State.all_submitted?(@all_numbers_present) == true
    end

    @some_numbers_missing %{
      "phx-FpFUEe4C66uTTgHH" => %{
        metas: [
          %{
            number: 6.0,
            admin: false
          }
        ]
      },
      "phx-FpFUEgWEsnjpeAFB" => %{
        metas: [
          %{
            number: nil,
            admin: false
          }
        ]
      }
    }

    test "false when some numbers missing" do
      assert State.all_submitted?(@some_numbers_missing) == false
    end

    @none_submitted %{
      "phx-FqW4rL6PMfDn5gQI" => %{
        metas: [
          %{
            only_viewing: false,
            name: "other",
            number: nil,
            phx_ref: "FqW4rRHpnqjljAbI",
            phx_ref_prev: "FqW4rRGmgvjljAaI"
          }
        ]
      },
      "phx-FqW4rMfOcZBLhgUI" => %{
        metas: [
          %{
            only_viewing: false,
            name: "De Wet",
            number: nil,
            phx_ref: "FqW4rR-mFYDljAgF",
            phx_ref_prev: "FqW4rR92lVjljAJC"
          }
        ]
      }
    }

    test "false when all numbers missing" do
      assert State.all_submitted?(@none_submitted) == false
    end
  end

  describe("parse_name/1") do
    test "does not change regular names" do
      assert State.parse_name("De Wet Blomerus") == "De Wet Blomerus"
    end

    test "truncates long names" do
      assert State.parse_name("Kristian De Wet Blomerus The 2nd") ==
               "Kristian De Wet Blomer..."
    end
  end

  describe("will_change?/2") do
    @assigns %{name: "De Wet", number: 10, admin: true}
    @subset %{name: "De Wet", number: 10}
    test "false if values are the same" do
      assert State.will_change?(@assigns, @subset) == false
    end

    @subset %{name: "De Wet", number: 7}
    test "true if there are changed values" do
      assert State.will_change?(@assigns, @subset) == true
    end
  end
end
