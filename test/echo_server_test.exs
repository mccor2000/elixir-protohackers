defmodule EchoServerTest do
  require Logger

  use ExUnit.Case

  test "echo" do
    case :gen_tcp.connect(~c"localhost", 8080, mode: :binary, active: false) do
      {:ok, socket} ->
        assert :gen_tcp.send(socket, "foo") == :ok
        assert :gen_tcp.send(socket, "bar") == :ok
        :gen_tcp.shutdown(socket, :write)
        assert :gen_tcp.recv(socket, 0, 10000) == {:ok, "foobar"}

      {:error, reason} ->
        Logger.error(reason)
        assert false
    end
  end
end
