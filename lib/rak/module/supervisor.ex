defmodule Rak.Module.Supervisor do
  @moduledoc """
  Defines the behavior expected from Rak module
  instance supervisors.

  This module is responsible for keeping instances up and running.

  Note that supervision is optional: you may start instances which
  the service keeps track of, but which remain unsupervised.

  The use of an instance supervisor itself is also optional.

  ```elixir
  defmodule MyApp.MyModule do
    use Rak.Module,
      supervisor: false
  ```
  """
  defmacro __using__(config) do
    quote do
      use Supervisor

      @behaviour Rak.Module.Supervisor

      def child_spec(args), do: supervisor(__MODULE__, [args])

      def start_link(args) do
          Supervisor.start_link(__MODULE__, args, name: __MODULE__)
      end

      def init(_args) do
          Supervisor.init([], strategy: :one_for_one)
      end
    end
  end
end
