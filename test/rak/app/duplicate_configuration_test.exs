defmodule RakTest.App.DuplicateConfig do
  use ExUnit.Case

  defmodule MyApp do
    defmodule Service, do: use Rak.Service

    use Rak.App,
      service: MyApp.Service
  end

  test "Application starts properly" do
    {:ok, pid} = MyApp.start(:normal, [])
    assert [{MyApp.Service, _, :worker, [MyApp.Service]}] = MyApp.children
    MyApp.stop(pid)
  end
end
