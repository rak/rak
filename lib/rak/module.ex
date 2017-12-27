defmodule Rak.Module do
  @moduledoc """
  Defines the behavior expected from module components.

  Module components can be broken into four parts:

    - The module itself, acting as an OTP supervisor
    - The service, in charge of receiving and processing messages and commands
    - The instance supervisor, in charge of supervising children
    - The instance module

  In general, the module itself won't do anything other than supervising, while
  the module's service will be in charge of routing incoming messages. You may,
  however, add entry point functions that will act as an interface to the underlying
  service.

  The instance supervisor and the instance module are optional. Instance
  module may be either `GenServer` or Rak submodules; the only
  requirement is that they export a `child_spec/1` method returing
  the child specification for the module itself.
  """

  defmacro __using__(config) do
    children = [
      setup_supervisor(config[:supervisor]),
      setup_service(config[:service])
    ] |> Enum.filter(fn (val) -> val != nil end)

    quote do
      use Supervisor

      def rak_module?, do: true

      def child_spec(args), do: supervisor(__MODULE__, [args])

      def start_link(args) do
          Supervisor.start_link(__MODULE__, args, name: __MODULE__)
      end

      def init(args) do
          Supervisor.init(unquote(children), strategy: :one_for_one)
      end
    end
  end

  def setup_supervisor(false), do: nil
  def setup_supervisor(nil) do
    quote do
      __MODULE__.Supervisor.child_spec(args)
    end
  end

  def setup_supervisor(supervisor) do
    quote do
      unquote(supervisor).child_spec(args)
    end
  end

  def setup_service(false), do: nil
  def setup_service(nil) do
    quote do
      __MODULE__.Service.child_spec(args)
    end
  end

  def setup_service(service) do
    quote do
      unquote(service).child_spec(args)
    end
  end
end
