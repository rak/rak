defmodule Rak.Message do
  @moduledoc """
  Defines the behavior expected from message components.

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
  defstruct module: "", method: "", data: ""
  alias Rak.Message, as: Message


  @type message :: any

  @type data :: binary | bitstring

  @callback create(data :: data) :: message

  @callback create(module :: atom, method :: atom, data :: any) :: message

  @callback serialize(message :: message) :: data

  @callback deserialize(data :: data) :: message

  defmacro __using__(_) do
    quote do
      @behaviour Rak.Message

      defstruct module: "", method: "", message: ""
      alias __MODULE__, as: Message
    end
  end
end
