defmodule Rak.Module.Instance do
  @moduledoc """
  Defines the behavior expected from Rak module instances.

  Module instances can represent one of the following:

    1. A *sharding unit*, which takes care offloading
       asynchronous operations;
    2. An *isolation unit*, responsible of preserving a certain
       state that concerns only a certain number of players;
    3. A *logical unit*, responsible of separating code into
       clearly defined concerns;

  Module instances are often GenServers, but may also be
  Rak modules themselves in certain cases; thanks to this,
  you may use Rak modules to create supervision trees as
  deep as you may like.
  """
  @callback create(config :: any, supervise? :: boolean) :: pid

  @callback get(hashkey :: any, create? :: boolean) :: pid

  @callback destroy(pid) :: nil

  defmacro __using__(config) do
    state = get_state(config[:state])
    quote do
      use GenServer
      import Supervisor.Spec

      @behaviour Rak.Module.Instance

      def child_spec(args), do: worker(__MODULE__, args)

      def start_link(args) do
        GenServer.start_link(__MODULE__, args, name: __MODULE__)
      end

      def init(_), do: {:ok, unquote(state)}
    end
  end

  defp get_state(nil), do: %{}
  defp get_state(state), do: state
end
