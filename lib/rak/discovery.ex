defmodule Rak.Discovery do
  @moduledoc """
  Defines the behavior expected from discovery components.

  Discovery components are in charge of:

    1. Topology discovery
    2. Clustering
    3. Sharding between end-user modules
  """

  # Todo: event callback functions for discovered and disappeared

  @doc """
  Retrieve the child specification.
  """
  @callback child_spec(config :: list()) :: {atom, any} | %{optional(any) => any}

  @doc """
  Return the number of nodes in the current cluster.
  """
  @callback get_node_count() :: integer

  @doc """
  Retrieve the local node ID.
  """
  @callback get_local_id() :: String.t

  @doc """
  Retrieve the local node rank.
  """
  @callback get_local_rank() :: integer

  @doc """
  Retrieve a server ID for a given hashkey.
  """
  @callback get_id(hashkey :: String.t) :: String.t

  @doc """
  Retrieve a server rank for a given hashkey.
  """
  @callback get_rank(hashkey :: String.t) :: integer

  @doc """
  Send a message to all nodes in a cluster.

  Messages should target a Rak module.
  """
  @callback broadcast(module :: atom, method :: atom, message :: any) :: any

  defmacro __using__(_) do
    quote do
      @behaviour Rak.Discovery
    end
  end
end
