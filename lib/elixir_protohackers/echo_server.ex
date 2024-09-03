defmodule ElixirProtohackers.EchoServer do
  use GenServer

  require Logger

  def start_link([] = _opts) do
    GenServer.start_link(__MODULE__, :no_state)
  end

  defstruct [:listen_socket]

  @impl true
  def init(:no_state) do
    opts = [
      mode: :binary,
      active: false,
      reuseaddr: true,
      exit_on_close: false
    ]

    case :gen_tcp.listen(8080, opts) do
      {:ok, ls} ->
        Logger.info("Starting echo server")
        state = %__MODULE__{listen_socket: ls}
        {:ok, state, {:continue, :accept}}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl true
  def handle_continue(:accept, %__MODULE__{} = state) do
    case :gen_tcp.accept(state.listen_socket) do
      {:ok, socket} ->
        handle_connection(socket)
        {:noreply, state, {:continue, :accept}}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  defp handle_connection(socket) do
    case recv_until_closed(socket, _buffer = "") do
      {:ok, data} ->
        case :gen_tcp.send(socket, data) do
          :ok -> Logger.info("echo-ed")
          {:error, reason} -> Logger.info("failed to echo #{inspect(reason)}")
        end


      {:error, reason} ->
        Logger.error("failed to receive data: #{inspect(reason)}")
    end

    :gen_tcp.close(socket)
  end

  defp recv_until_closed(socket, buffer) do
    case :gen_tcp.recv(socket, 0, 10_000) do
      {:ok, packet} ->
        recv_until_closed(socket, [buffer, packet])

      {:error, :closed} ->
        {:ok, buffer}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
