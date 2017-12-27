defmodule Rak do
  @moduledoc """
  Rak main API
  """

  @doc """
  Return the version of Rak currently used.
  """
  def version, do: Rak.Mixfile.project[:version]
end
