defmodule RakTest.App.ComponentGroups.Module do
  use ExUnit.Case

  defmodule MyApp do
    defmodule ModuleOne, do: use Rak.Module,
      supervisor: false,
      service: false
    defmodule ModuleTwo, do: use Rak.Module,
      supervisor: false,
      service: false
    defmodule ModuleThree, do: use Rak.Module,
      supervisor: false,
      service: false
    defmodule ModuleFour, do: use Rak.Module,
      supervisor: false,
      service: false

    use Rak.App,
      module: MyApp.ModuleFour,
      module: :auto,
      module: MyApp.ModuleOne
  end

  test "Modules are started in the correct order" do
    {:ok, pid} = MyApp.start(:normal, [])
    modules = MyApp.children
      |> Enum.map(fn ({module, _, _, _}) -> module end)

    assert List.first(modules) == MyApp.ModuleFour
    assert List.last(modules) == MyApp.ModuleOne

    MyApp.stop(pid)
  end

  test "Modules not specified in the list are auto-loaded" do
    {:ok, pid} = MyApp.start(:normal, [])
    modules = MyApp.children
      |> Enum.map(fn ({module, _, _, _}) -> module end)

    assert Enum.member?(modules, MyApp.ModuleTwo)
    assert Enum.member?(modules, MyApp.ModuleThree)

    MyApp.stop(pid)
  end

  test "No duplicates are found" do
    {:ok, pid} = MyApp.start(:normal, [])
    assert length(MyApp.children) == 4
    MyApp.stop(pid)
  end
end
