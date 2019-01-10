### Purpose

The purpose of this hiring exercise is to test out your level in Elixir/OTP and see if you are a real problem solver which is one of Zenaton core values.

### General acceptance criteria

- All code is in `git` repo (candidate can use his/her own github account).
- OTP application is a mix project
- Engine application name is `:zenaton_engine` (main Elixir module is `ZenatonEngine`).
- Agent application name is `:zenaton_agent`  (main Elixir module is `ZenatonAgent`)
- Agent Interface is just set of public functions of `ZenatonAgent` (no API endpoint, no REST/SOAP )
- Applications should **not** use any database / disc storage. All needed data should be stored only in application memory.
- Candidate can use any Elixir or Erlang library he/she wants to.(but app can be written in pure Elixir/ Erlang/ OTP)
- Code accuracy also matters. Readable, safe, refactorable code is plus.
- Test implementation is plus.

### Heartbeat project

The hearbeat is a feature implemented between one engine and **n** agents. It is made to improve monitoring, resiliency to any network or infrastructure issues.

The main work is that agents send a `state`, with additional information periodically and the engine answers back with an `action` and `data`.

You are free to choose the connection protocol to make this possible (HTTP/TCP/Erlang message).

Possible state for an agent:
- **Starting**: transient state between command listen and listening
- **Stopping**: transient state between command unlisten and disconnection
- **Listening**: connected to queues
- **Sleeping**: disconnected from queues

**WARNING**: You don't have to work on the queues connection, it is not the purpose of this exercise.

#### Engine

the Engine **MUST** stores agents identificator in memory with his current state and details.

the Engine **MUST** stores `HEART_BEAT_PERIOD` in memory which can be changed via Ex shell (value in sec).

the Engine **MUST** also have a `messages_in_adhoc` Map. Eg. `messages_in_adhoc: %{"agent_1" => 3}` where 3 represents the number of message available for agents which can be also changed.

When Engine receives:
`state` === `starting`
**Then:** action=`listen` with `heart_beat_period`

When Engine receives:
`state` === `sleeping` AND `messages_in_adhoc` related to the agent id > 0
**Then:** action=`listen` with `heart_beat_period` and the `messages_in_adhoc` related to the agent id = 0

When Engine receives:
`state` === `listening` AND agent not active for more than `HEART_BEAT_PERIOD` related to the agent id 
**Then:** action=`sleep`

When Engine receives:
`state` === `stopping`
**Then:** delete the related agent_id in memory

##### Public methods accessible from iex
- `update_heart_beat_period\1`
- `increment_messages_in_adhoc\1`

#### Agent

It should be possible to open **n** Agent Application. Like in Zenaton.


When: Agent is asked to listen **Then:** state=`starting`, Send heartbeat

When: User is running `active\0` method **Then:** if the Agent is state=`listening` it sends a fake message to Engine, the Engine must reset the `sleeping_timer` for this `agent_identificator`. If the Agent is in state=`sleeping`, it will make a listen (☝️), then do the same behaviour than when state=`listening`. If the agent is in state=`stopping`, it must do nothing. 

When: Agent is asked to stop **Then:** state=`stopping`, Send heartbeat, log kill message

When: Send heartbeat **Then:** cancel previous timer if any, plan timer to send a new heartbeat in `heart_beat_period`, if < 3 calls in previous `heart_beat_period` => contact the engine with state, identificator, RAM. It should receive a response from the engine instantly

When: receiving action=Sleep  Entering sleeping mode **Then:** state=sleeping, send heartbeat

When: receiving action=listen Entering listening mode **Then:** state=listening, send heartbeat

##### Public methods accessible from iex
- `listen\0`
- `active\0`
- `stop\0`

If you have some questions do not hesitate to open an issue on the repo 😬
