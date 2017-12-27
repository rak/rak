# Language selection

This document describes the selection process for the programming language used
by this project.

## Contributors

  - Marc Trudel (https://github.com/stelcheck)

## Issue

Select a programming language to program this project with. The language
(or its ecosystem) should provide as many tools as possible to help simplify
the maintenance of this project. It should also provide good tools for
dealing with the development of distributed systems and be able to provide
a high-level of reliability.

## Decision

[Elixir](http://elixir-lang.github.io/) was selected as the language for this
project.

## Group

  - Core

## Assumptions

Much of the time spent when developing game servers is spent on what
we could call *the backplane*; that is, the networking between client
and servers, or between multiple servers.

Also, game servers are not only stateful, but the number of states at any
given time can be quite daunting; an early misarchitecture of how
such states are structured, and how they interact, can have disastrous
consequences on maintainability.

Game server developers often spend a considerable amount of time on
base tooling - that is, selecting test or SCA tools. Some simply give
up due to the time tax imposed by such research.

Documentation is often rare and somewhat inaccessible. This goes into
direct conflicts with how complex game servers often become, and
greatly impacts their maintainability.

## Constraints

Low-latency gaming can impose severe requirements on performance; ideally,
the selected language would allow for such level of performances.

## Positions

Since this document predates the formal creation of this project, no
opponents/proponents listing are provided.

The following languages were considered:

  * [TypeScript (Node.js)](https://www.typescriptlang.org/)
  * [Go](https://golang.org)
  * [C#](https://en.wikipedia.org/wiki/C_Sharp_(programming_language))
  * [Erlang](https://www.erlang.org/)
  * [Elixir](http://elixir-lang.github.io/)

## Argument

All languages listed here have some form of standardized tooling.

TypeScript (thanks to NPM) and Go are probably 

Go and Elixir have de-facto network backplane for server-to-server 
communication. C# appears to have a few alternatives, but nothing 
coming from standard libraries. While exposing methods as network
RPC in Go [comes with some additional requirements](https://golang.org/pkg/net/rpc/),
exposing methods as RPC in Elixir comes with no requirements.

Only Elixir provides a built-in mechanism for clustering across multiple
servers.

Both Go and Elixir not only standardize how to embed documentation with the
code, but also come with first-class documentation generation tools. Elixir goes
even further by auto-publising the documentation to a centralized hosting site
when a package is released.

TypeScript/JavaScript provide no standardized architecture to structure code. This
can lead to developers feeling quite lost, or making architectural misteps that later
become hard to correct. It also relies on a sub-process architecture for parallelism. 

Conversely, Go and C# have more standard architectures, and they 
tend to rely more on a threading model; this allows for more 
tunable performance behaviors. However, this comes with a lost 
of simplicity that drove many developers towards the Node.js model in 
the first place.

Elixir, with the virtual machine and OTP library it inherits from Erlang, 
abstract threading in a similar way that Go does while providing a lock-free
communication layer between processes (thanks to OTP). Combined with its
built-in networking layer, Elixir provides a runtime environment that makes it
seemingly quite easy to scale out code as a given project's scope and scale
evolves.

That said, much of the aforementioned benefit are provided by BEAM, the Erlang
VM; therefore, all previously mentioned benefits are shared between Erlang and 
Elixir. However, Elixir provides better overall tooling and a more approchable
language syntax than Erlang.

Performance-wise, only Go appeared to fit the soft-requirement regarding
low-latency gaming.

## Implications

Selecting Elixir means that additional ecosystem component(s) may be required in the
future to deal with low-latency gaming.

## Scheduled release

0.1.0

## Notes

No additional notes.
