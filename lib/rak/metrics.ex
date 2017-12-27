defmodule Rak.Metrics do
  @moduledoc """
  Defines the behavior expected from metrics components.

  Metrics components are responsible for:

    1. Gathering Rak metrics (from modules, services, etc)
    2. Expose an API to keep track of application-level metrics
    3. Expose or forward the metrics to relevant services
  """
  @callback child_spec(config :: list()) :: {atom, any} | %{optional(any) => any}

  @callback increment(key :: atom, val :: integer) :: nil

  @callback decrement(key :: atom, val :: integer) :: nil

  @callback add(key :: atom, val :: any) :: nil

  @callback set(key :: atom, val :: any) :: nil

  @callback get(key :: atom) :: nil

  defmacro __using__(_) do
    quote do
      @behaviour Rak.Metrics
    end
  end
end
