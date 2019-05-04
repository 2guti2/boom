defmodule Boom.MailNotifier.TextContent do
  import Boom.MailNotifier.Helpers

  def build(%ErrorInfo{controller: nil, stack: stack}) do
    stack_to_string(stack)
  end

  def build(%ErrorInfo{
        name: name,
        controller: controller,
        action: action,
        request: request,
        stack: stack
      }) do
    [exception_basic_text(name, controller, action) <> "\n"] ++
      request_info_to_string(request) ++
      stack_to_string(stack)
  end

  defp request_info_to_string(request) do
    [
      "Request Information:\n",
      "Path: #{request.path}\n",
      "Method: #{request.method}\n",
      "URL: #{request.url}\n"
    ]
  end

  defp stack_to_string(stack) do
    Enum.map(stack, &(Exception.format_stacktrace_entry(&1) <> "\n"))
  end
end
