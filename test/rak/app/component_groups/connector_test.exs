defmodule RakTest.App.ComponentGroups.Connector do
  use ExUnit.Case

  defmodule MissingSessionApp do
    defmodule Message, do: nil
    defmodule ConnectorOne, do: use Rak.Module,
      supervisor: false,
      service: false

    use Rak.App,
      connector: [
        module: MyApp.ConnectorOne,
        message: MyApp.Message,
      ]
  end

  test "Missing session module raises an exception" do
    assert_raise Rak.Exception, "Missing session module for connector Elixir.MyApp.ConnectorOne", fn ->
      Rak.App.config_children([
        connector: [
          module: MyApp.ConnectorOne,
          message: MyApp.Message,
        ]
      ], [
        app_module: MissingSessionApp
      ])
    end
  end

  defmodule MyApp do
    defmodule Message, do: nil
    defmodule Session, do: use Rak.Session
    defmodule ConnectorOne, do: use Rak.Module,
      supervisor: false,
      service: false
    defmodule ConnectorTwo, do: use Rak.Module,
      supervisor: false,
      service: false

    use Rak.App,
      connector: [
        module: MyApp.ConnectorOne,
        message: MyApp.Message,
        session: MyApp.Session
      ],
      connector: [
        module: MyApp.ConnectorTwo,
        message: MyApp.Message,
        session: MyApp.Session
      ]
  end

  test "Modules are started in the correct order" do
    {:ok, pid} = MyApp.start(:normal, [])
    modules = MyApp.children
      |> Enum.map(fn ({module, _, _, _}) -> module end)

    assert length(modules) == 3
    assert List.first(modules) == MyApp.Session
    assert List.last(modules) == MyApp.ConnectorTwo

    MyApp.stop(pid)
  end
end
