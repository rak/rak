defmodule Rak.Module.Service do
  @moduledoc """
  Defines the behavior expected from Rak module services.

  Module services are responsible for:

    1. Receiving client requests
    2. Executing, routing and/or forwarding messages
    3. Creating and terminating module instances as needed

  In the case where a Rak module is a sub-module, the service
  may receive forwarded RPC and messages from the parent.
  """
  defmodule BeforeCompile do
    @moduledoc false

    defmacro __before_compile__(env) do
      level = get_log_level(env)
      quote do
        def cast(name, message, session) do
          Logger.log(unquote(level), "Received unknown message", [
            module: __MODULE__,
            name: name,
            message: message,
            session: session
          ])
        end

        def call(name, message, session) do
          Logger.log(unquote(level), "Received unknown rpc", [
            module: __MODULE__,
            name: name,
            message: message,
            session: session
          ])
        end
      end
    end

    defp get_log_level(:prod), do: :debug
    defp get_log_level(_), do: :warn
  end

  defmacro __using__(config) do
    state = get_state(config[:state])
    quote do
      use GenServer
      import Supervisor.Spec
      import Rak.Module.Service
      require Logger

      @behaviour Rak.Module.Service
      @before_compile Rak.Module.Service.BeforeCompile

      def child_spec(args), do: worker(__MODULE__, args)

      def start_link(args) do
        GenServer.start_link(__MODULE__, args, name: __MODULE__)
      end

      def init(_), do: {:ok, unquote(state)}
    end
  end

  @doc """
  message macro

  ```elixir
  defmodule MyModule.Service do
    use Rak.Module.Service

    message messageName %{ count: count } do
      {:noreply, state}
    end
  end
  ```
  """
  defmacro message({name, meta, [message]}, do: block) do
    quote do
      @doc false
      def cast(unquote(name), unquote(message)) when unquote(meta) do
        GenServer.cast({:message, unquote(name), unquote(message), nil})
      end

      @doc false
      def cast(unquote(name), unquote(message), session) when unquote(meta) do
        GenServer.cast({:message, unquote(name), unquote(message), session})
      end

      @doc false
      def handle_cast({:message, unquote(name), unquote(message), session}, _, state) do
        state   = Macro.var(state, nil)
        session = Macro.var(session, nil)

        unquote(block)
      end
    end
  end

  @doc """
  message macro

  ```elixir
  defmodule MyModule.Service do
    use Rak.Module.Service

    rpc messageName %{ count: count } do
      {:reply, %{ count: count + 1}, state}
    end
  end
  ```
  """
  defmacro rpc({name, meta, [message]}, do: block) do
    quote do
      @doc false
      def call(unquote(name), unquote(message)) when unquote(meta) do
        GenServer.call({:rpc, unquote(name), unquote(message), nil})
      end

      @doc false
      def call(unquote(name), unquote(message), session) when unquote(meta) do
        GenServer.call({:rpc, unquote(name), unquote(message), session})
      end

      @doc false
      def handle_call({:rpc, unquote(name), unquote(message), session}, _, state) do
        state   = Macro.var(state, nil)
        session = Macro.var(session, nil)

        unquote(block)
      end
    end
  end

  defp get_state(nil), do: %{}
  defp get_state(state), do: state
end
