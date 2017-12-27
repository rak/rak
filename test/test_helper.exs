ExUnit.start()

defmodule RakTest.Helper do
  defmacro __using__(config) do
    module = config[:module]
    quote do
      use ExUnit.Case
      doctest unquote(module)

      # Coverex currently does not properly ignore
      # the auto-generated __info__ function; we run
      # it automatically to make sure coverage analysis
      # results remain accurate
      #
      # Ref: https://github.com/alfert/coverex/issues/25
      test "Load function list" do
        unquote(module).__info__(:functions)
      end
    end
  end
end
