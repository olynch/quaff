# Features for Sure

- DM can load code on the fly
- Event queue for actions
- Dynamic environment

# Implementation

- We need a generalized framework for capabilities and actions that use those capabilities

## The two types of plugins

### Events

- Events are messages sent between agents. An event plugin can add a new type of event, along with associated methods for dealing with that event. Events can be subscription requests, events from subscriptions, replies to subscribed events, or general events, which can be sent to any agent.
- Examples
    - Sight events sent by the map, what each player can see
    - Damage events sent by other players, monsters, traps, etc.
    - "your-turn" events sent by the Chronoqueue

### Agents

- Agents are running processes that message other agents.
- Agents provide subscriptions services for events. Agent A can send a message to agent B saying that they would like to be notified about a certain type of event, and whenever that type of event happens, agent B sends a message to agent A. There are two types of subscriptions: blocking and non-blocking. Every time an event fires, the agent who sent the event waits for all of their blocking subscribers to reply before continuing. Subscriptions can be temporary.
- Examples
    - The Map (manages how agents relate to each other)
    - The Chronoqueue (a global clock for stuff that takes time to complete)
    - PC controllers (the only thing running on the client side)
    - PCs (all the actual game logic is run server side, only the decision making is run client side). Broken up into
      - Stats (each stat could be an agent, or stuff could be bundled)
      - Abilities (could have actual ability logic, or could just be "mutex" for using abilities, ie. the PC has to "acquire" the ability mutex in order to perform an action, and the ability mutex isn't released until the event loop sends an action complete message)
    - Monsters (Spectrum between completely independent, like a trap or a dungeon feature, or completely under the DMs control, just like a PC)
