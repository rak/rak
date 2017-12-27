defmodule RakTest.App.EmptyConfig do
  use ExUnit.Case

  defmodule MyApp do
    use Rak.App, []
  end

  test "Application starts properly" do
    {:ok, pid} = MyApp.start(:normal, [])
    assert MyApp.children== []
    MyApp.stop(pid)
  end
end
