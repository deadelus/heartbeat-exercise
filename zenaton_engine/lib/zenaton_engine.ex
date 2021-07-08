defmodule ZenatonEngine do
use GenServer

# functions

def start_link(opts) do
  GenServer.start_link(__MODULE__, nil, opts)
end

def update_heart_beat_period(hearbeat) do
  GenServer.cast(__MODULE__, {:update, {:heartbeat, hearbeat}})
end

def increment_messages_in_hadoc(agent_id) do
  GenServer.cast(__MODULE__, {:update, {:messages, agent_id}})
end

# server callbacks
@impl true
def init(init_arg) do
  args = cond do
    is_integer(init_arg.heart_beat_period) && is_map(init_arg.messages_in_adhoc) -> init_arg
    true -> %{:heart_beat_period => 3, :messages_in_adhoc => %{}}
  end
  {:ok, args}
end

@impl true
def handle_cast({:update, {:heatbeat, hearbeat}}, state) do
  new_state = Map.update!(state, :heart_beat_period, hearbeat)
  {:noreply, new_state}
end

@impl true
def handle_cast({:update, {:messages, agent_id}}, state) do
  messages = state.messages_in_adhoc
  {_, updated_messages_in_adhoc} = Map.get_and_update!(messages, agent_id, fn current_val ->
    {current_val, current_val + 1}
  end)
  new_state = Map.update!(state, :messages_in_adhoc, updated_messages_in_adhoc)
  {:noreply, new_state}
end

# action
@impl true
def handle_call(:heartbeat, {agent_pid, :starting}, state) do
  heart_beat_period = state.heart_beat_period
  new_state = if !(state |> Map.has_key?(agent_pid)) do
    state.messages_in_adhoc |> Map.put(agent_pid, 3)
    state |> Map.put(agent_pid, :starting)
  else
    state
  end
  {:reply, {:listening, {:heatbeat, heart_beat_period}}, new_state}
end

@impl true
def handle_call(:heartbeat, {agent_pid, :listening}, state) do
  heart_beat_period = state.heart_beat_period
  messages_in_adhoc = Map.get(state.messages_in_adhoc, agent_pid)

  if !(messages_in_adhoc > 0) do
    {_, map} = Map.get_and_update!(state.messages_in_adhoc, agent_pid, fn val ->
      {val, 0}
    end)
    new_state = Map.update!(state, :message_in_adhoc, map) |> Map.put(agent_pid, :sleeping)
    {:reply, {:sleeping, {:heatbeat, heart_beat_period}}, new_state}
  else
    new_state = state |> Map.put(agent_pid, :listening)
    {:reply, {:listening, {:heatbeat, heart_beat_period}}, new_state}
  end
end

@impl true
def handle_call(:heartbeat, {agent_pid, :sleeping}, state) do
  heart_beat_period = state.heart_beat_period
  messages_in_adhoc = Map.get(state.messages_in_adhoc, agent_pid)
  new_state = if messages_in_adhoc > 0 do
    {_, messages_in_adhoc} = Map.get_and_update!(state.messages_in_adhoc, agent_pid, fn val ->
      {val, 0}
    end)
    state |> Map.update!(:message_in_adhoc, messages_in_adhoc)
  else
    state
  end |> Map.put(agent_pid, :sleeping)
  {:reply, {:listening, {:heatbeat, heart_beat_period}}, new_state}
end

@impl true
def handle_call(:heartbeat, {agent_pid, :stopping}, state) do
  messages_in_adhoc = Map.pop(state.message_in_adhoc, agent_pid)
  new_state = state
                |> Map.put(:message_in_adhoc, messages_in_adhoc)
                |> Map.pop(agent_pid)
  {:reply, {nil, nil}, new_state}
end

end
