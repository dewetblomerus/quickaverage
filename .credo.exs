# Configuration for Credo
# To see all options, delete this file and run `mix credo.gen.config`.

%{
  configs: [
    %{
      name: "default",
      strict: true,
      checks: [
        {Credo.Check.Readability.ModuleDoc, false}
      ]
    }
  ]
}
