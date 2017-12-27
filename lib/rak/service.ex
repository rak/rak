defmodule Rak.Service do
  @moduledoc """
  Defines the behavior expected from service components.

  There should normally be only one service component per
  Rak application, but no limitations are in place.

  The service component should normally be in charge of
  managing the application's lifespan.
  """

  defmacro __using__(_) do
    quote do
      use GenServer
      import Supervisor.Spec

      def child_spec(args), do: worker(__MODULE__, [args])

      def start_link(args) do
          GenServer.start_link(__MODULE__, args, name: __MODULE__)
      end

      def init(_args) do
          state = %{}
          {:ok, state}
      end
    end
  end
end
