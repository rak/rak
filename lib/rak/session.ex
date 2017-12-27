defmodule Rak.Session do
  @moduledoc """
  Defines the behavior expected from session components.

  Sessions here must be understood as connection states;
  whereas the underlying connection may currently be disconnected,
  the server itself may still consider the target device as present,
  buffer messages, etc.

  Session components are responsible for:

    1. Managing the connection's states
    2. Communication protocol: message reliability and ordering

  Session components must receive a Message component module, and use it
  for serializing and deserializing messages.
  """

  @doc """
  Retrieve the child specification.
  """
  defmacro __using__(_) do
    quote do
      use Rak.Module,
        service: false,
        supervisor: false
    end
  end
end
