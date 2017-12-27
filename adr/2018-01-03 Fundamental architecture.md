# Fundamental architecture

This document has for goal to describe the overall architecture
of the project, by:

  - Define the key architecture terms for this project
  - Describe the core's responsibilities
  - Provide a list of component groups

## Contributors

  - Marc Trudel (https://github.com/stelcheck)

## Issue

Create a project architecture allowing for pluggability
and extensibility.

## Decision

### Key terms

#### Core

The main project; defines how component groups relate to each other,
their behaviours, how they get started and how they get terminated.

#### End-user

Developers creating or developing on a project using Rak.

#### Application

```plaintext
                                      +-------------------+
                                      |                   |
                                      |                   |
                                      |    Application    |
                                      |                   |
                                      |                   |
                                      +---------+---------+
                                                |
                                      +---------v---------+
                                      |                   |
                                      |                   |
                                      |     Supervisor    |
                                      |                   |
                                      |                   |
           +--------------------+-----+-------------------+----+--------------------------+
           |                    |                              |                          |
+----------v-------+  +---------v--------+            +--------v-----------+ +------------v-------+
|                  |  |                  |            |                    | |                    |
|     Service      |  |    Connector     |     ...    |      ModuleOne     | |     ModuleTwo      |
|                  |  |                  |            |                    | |                    |
+------------------+  +--------+---------+            +--------+-----------+ +---------+----------+
                               |                               |                       |
                      +--------+---------+            +--------+-----------+ +---------+----------+
                      |                  |            |                    | |                    |
                      |       ...        |            |       ...          | |        ...         |
                      |                  |            |                    | |                    |
                      +------------------+            +--------------------+ +--------------------+
```

Elixir Application defining component groups, and the startup order of components
within those groups.

#### Component groups

Fundamental responsibilities which the core will operate, but external
libraries will take care of.

#### Service

Application or module communication interface; generally, these endpoints 
will be accessible through the networking stack.

#### Module

> Module structure 

```plaintext
         +-----------------------+
         |                       |
         |        Module         |
         |    (OTP Supervisor)   |
         |                       |
         +-+------------------+--+
           |                  |
+----------v--+          +----v----------+
|             |          |               |
|   Service   |          |   Supervisor  |
|             |          |               |
+-------------+          +---------------+
                      +------v---+   +--v-------+
                      |          |   |          |
                      | Instance |   | Instance |
                      |          |   |          |
                      +----------+   +----------+
```

End-user module. Unlike Elixir modules, Rak modules generally come with:

  - Service
  - Supervisor (OTP Supervisor)
  - Instance

Modules may have other Elixir proceseses or Rak sub-modules as instances.

Modules and instances *must* provide a `child_spec` function that will 
be used at runtime for initialization.

### Core

The core itself provides no functionalities whatsoever, aside
from managing runtime execution phases and defining behaviours 
(as in Elixir `@behaviour`).

Additional tooling may be provided by the core codebase (such
as CLI tools for project creations, project templates, and so on).

### Component groups

The following component groups were defined

| Name      | Description
| --------- | ------------------------------------------------------------ |
| metrics   | Metrics system and API                                       | 
| service   | Application level service and API                            |
| module    | End-user modules                                             |
| discovery | Discovery, clustering and sharding                           |
| session   | Connection session management and message dispatch           |
| message   | Message format, serialization and deserialization            |
| connector | Network connector for clients to connect to the server       |

## Group

  - Core
  - Components
  - Subsystems

## Assumptions

Elixir, thanks to its Erlang roots, already ships with the base blocks for
doing server-to-server communication. However, it does not ship with any 
server-to-client communication libraries or tools.

This is generally the layer which benefits the most from customization when
making games.

## Constraints

<!-- 
  Capture any additional constraints to the environment that the chosen 
  alternative (the decision) might pose.
-->

## Positions

### Thrift

[Thrift](http://thrift-tutorial.readthedocs.io/en/latest/thrift-stack.html)
possesses the following three layers:

  - Transport
  - Protocol
  - Service

However, Thrift itself does not care about operational information; it only
cares about networking, message format and service execution model.

### Protobuf

Protobuf allows for the customization of the network stack; indeed, one may define
multiple services and RPC, and even define stream RPC calls (one well-known example
of this being GRPC, but the `stream` keyword would also be perfectly legal in a plain
Protobuf 3 definition file).

Networking is done through code stubs.

Just like Thrift, it does not care about anything else but the
communication layers.

### Component groups

Component groups are basically a fixed ordered stack of groups containing
an arbitrarily ordered set of components. The order should reflect
the desired runtime initialization and termination sequence.

The following initial component groups stack is suggested.

| metrics   | Metrics system and API                                       | 
| service   | Application level service and API                            |
| module    | End-user modules                                             |
| discovery | Discovery, clustering and sharding                           |
| session   | Connection session management and message dispatch           |
| message   | Message format, serialization and deserialization            |
| connector | Network connector for clients to connect to the server       |

`connector` takes the same responsibility as `Transport` in Thrift, and 
`message` the same as `Protocol` (the word Protocol was avoided due to the 
existence of Elixir Protocols).

Within a group, multiple implementations may be added; for instance, multiple
connectors may be specified. Conversely, some groups can be left empty (a good
example of this would be for testing, where the connector and session groups may
not be required).

## Argument

Component groups can include, but also extend, the categorization provided by 
systems such as Thrift and GRPC. Not only that, but it allows for a clear separation
of concerns; for instance, instead of having fixed message format part of core,
a standard message format may be externalized (the core's project creation tool
may still include the externalized as a base dependency for convenience).

Additional component groups can also be added for purposes other than networking.

## Implications

For each component groups, at least one default implementation should be provided.

The interface between end-user code and component groups remain to be defined; similarly,
the fixed responsibilities for each component groups remain to be defined as well.

## Scheduled release

0.2.0

## Notes

http://thrift-tutorial.readthedocs.io/en/latest/thrift-stack.html
https://grpc.io/docs/quickstart/node.html

