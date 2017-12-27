defmodule Rak.Connector do
  @moduledoc """
  Defines the behavior expected from connector components.

  Connector components are responsible for:

    1. Accepting and processing connections from client devices
    2. Starting or connection a given connection to a session

  Connector components must receive a Message component module and
  a Session component module as part of their configuration.

  Connector modules are **not** responsible for message parsing.

  The received Session module should be forwarded the Message module
  as part of its configuration.
  """

  @doc """
  Retrieve the child specification.
  """
  @callback child_spec(config :: list()) :: {atom, any} | %{optional(any) => any}

  defmacro __using__(_) do
    quote do
      @behaviour Rak.Connector
    end
  end
end
