defmodule QuickAverage.RoomCoordinatorTest do
  use ExUnit.Case
  alias QuickAverage.RoomCoordinator
  alias QuickAverageWeb.Presence

  @room_id "42"
  @payload %{
    joins: %{
      "phx-FxYZOsCGCCzGVQCC" => %{
        metas: [
          %{
            name: "De Wet",
            number: 3,
            only_viewing: false,
            phx_ref: "FxYZOsldA2ob6gAl",
            phx_ref_prev: "FxYZOsk0Pmcb6gDG"
          }
        ]
      },
      "phx-another" => %{
        metas: [
          %{
            name: "Another Person",
            number: 5,
            only_viewing: false,
            phx_ref: "FxYZOsldA2ob6gAl",
            phx_ref_prev: "FxYZOsk0Pmcb6gDG"
          }
        ]
      },
      "phx-viewer" => %{
        metas: [
          %{
            name: "Viewer Person",
            number: nil,
            only_viewing: true,
            phx_ref: "FxYZOsldA2ob6gAl",
            phx_ref_prev: "FxYZOsk0Pmcb6gDG"
          }
        ]
      }
    },
    leaves: %{
      "phx-FxYZOsCGCCzGVQCC" => %{
        metas: [
          %{
            name: "De Wet",
            number: nil,
            only_viewing: false,
            phx_ref: "FxYZOsk0Pmcb6gDG",
            phx_ref_prev: "FxYZOsj0EV4b6gAE"
          }
        ]
      }
    }
  }

  defp display_topic(room_id), do: "#{room_id}-display"

  describe "start_link/1" do
    test "Listens for PubSub events and broadcasts update events" do
      QuickAverageWeb.Endpoint.subscribe(display_topic(@room_id))
      pid = start_supervised!({RoomCoordinator, @room_id})

      Process.send(
        pid,
        %Phoenix.Socket.Broadcast{
          event: "presence_diff",
          payload: @payload
        },
        []
      )

      data =
        receive do
          {:refresh, data} -> data
        after
          1_000 -> dbg("nothing after 1s 🤷‍♂️")
        end

      assert %{
               average: 4.0,
               reveal_by_submission: true,
               user_list: [
                 %{
                   name: "De Wet",
                   number: 3,
                   only_viewing: false
                 },
                 %{
                   name: "Another Person",
                   number: 5,
                   only_viewing: false
                 },
                 %{
                   id: "phx-viewer",
                   name: "Viewer Person",
                   number: nil,
                   only_viewing: true
                 }
               ]
             } = data
    end
  end
end
