defmodule RakTest do
  use RakTest.Helper, module: Rak

  test "version can be accessed" do
    assert Rak.version === Rak.Mixfile.project[:version]
  end
end
