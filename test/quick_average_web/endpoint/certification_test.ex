defmodule QuickAverage.Endpoint.CertificationTest do
  use ExUnit.Case, async: false
  import SiteEncrypt.Phoenix.Test

  test "certification" do
    clean_restart(PhoenixDemo.Endpoint)
    cert = get_cert(PhoenixDemo.Endpoint)
    assert cert.domains == ~w/quickaverage.com www.quickaverage.com/
  end
end
