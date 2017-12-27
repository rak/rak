defmodule Rak.Exception do
  @moduledoc """
  Exception module

  Exception raised by Rak should always contain:

    1. Message: The nature of the exception
    2. Details: How the exception can be avoided
  """
  defexception [:message, :details]
end
