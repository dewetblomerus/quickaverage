defmodule QuickAverage.Endpoint.CertificationTest do
  use ExUnit.Case, async: false
  import SiteEncrypt.Phoenix.Test

  @tag :skip
  test "certification" do
    clean_restart(QuickAverageWeb.Endpoint)
    cert = get_cert(QuickAverageWeb.Endpoint)
    assert cert.domains == ~w/quickaverage.com www.quickaverage.com/
  end
end
