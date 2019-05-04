defmodule ErrorInfo do
  @enforce_keys [:reason, :stack]
  defstruct [:name, :reason, :stack, :controller, :action, :request]

  def build(%name{message: reason}, stack, conn) do
    %{build_without_name(reason, stack, conn) | name: name}
  end

  def build(%{message: reason}, stack, conn) do
    %{build_without_name(reason, stack, conn) | name: "Error"}
  end

  def build(reason, stack, conn) when is_binary(reason) do
    build(%{message: reason}, stack, conn)
  end

  def build(reason, stack, conn) do
    build(%{message: inspect(reason)}, stack, conn)
  end

  defp build_without_name(reason, stack, conn) do
    %ErrorInfo{
      reason: reason,
      stack: stack,
      controller: get_in(conn.private, [:phoenix_controller]),
      action: get_in(conn.private, [:phoenix_action]),
      request: build_request_info(conn)
    }
  end

  defp build_request_info(conn) do
    %{
      path: conn.request_path,
      method: conn.method,
      url: get_full_url(conn)
    }
  end

  # Credit: https://github.com/jarednorman/plugsnag/blob/master/lib/plugsnag/basic_error_report_builder.ex
  defp get_full_url(conn) do
    base = "#{conn.scheme}://#{conn.host}#{conn.request_path}"

    case conn.query_string do
      "" -> base
      qs -> "#{base}?#{qs}"
    end
  end
end
