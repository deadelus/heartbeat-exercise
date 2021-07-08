defmodule ZenatonAgent do
use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil)
  end

  def listen() do
    GenServer.call(__MODULE__, {:listen})
  end

  def active() do
    GenServer.call(__MODULE__, {:active})
  end

  def sleep() do
    GenServer.call(__MODULE__, {:sleep})
  end

  def stop() do
    GenServer.call(__MODULE__, {:stop})
  end

  defp send_heartbeat(pid) do
    # todo make a call to the Engine
    IO.inspect("SEND HEARTBEAT")
    IO.inspect(pid)
  end

  # server callbacks
  @impl true
  def init(_init_arg) do
    {:ok, :starting, {:continue, nil}}
  end

  @impl true
  def handle_call({:active}, _from, state) do
    case state do
      :listening ->
        send_heartbeat(self())
        {:reply, state, :listening, {:continue, nil}}
      :sleeping -> {:reply, state, :listening, {:continue, nil}}
      :stopping -> {:reply, state, :stopping, {:continue, nil}}
    end
  end

  @impl true
  def handle_call({:listen}, _from, state) do
    {:reply, state, :listening, {:continue, nil}}
  end

  @impl true
  def handle_call({:sleep}, _from, state) do
    {:reply, state, :sleeping, {:continue, nil}}
  end

  @impl true
  def handle_call({:stop}, _from, state) do
    {:reply, state, :stopping, {:continue, nil}}
  end

  @impl true
  def handle_continue(_continue, state) do
    send_heartbeat(self())
    {:noreply, state}
  end
end
