# Projects structure

The goal of this document is to describe the expected file
structure of Rak projects.

## Contributors

  - Marc Trudel (https://github.com/stelcheck) 

## Issue

Define a project structure for project using Rak. This structure should be 
instanciated by the `mix rak.new` command.

## Decision

### Initial file structure

> ~/Sources/project_name

```plaintext
project_name
├── config
│   ├── config.exs
│   ├── dev.exs
│   ├── prod.exs
│   └── test.exs
├── .gitignore
├── .iex.exs
├── lib
│   ├── mix
│   │   └── .placeholder
│   ├── project_name
│   │   └── modules
│   │       └── .placeholder
│   └── project_name.ex
├── mix.exs
├── mix.lock
└── test
    └── test_helper.exs
```

The project's file structure is essentially the output of 
`mix new` with the addition of:

  * .iex.exs, customising `iex`
  * `config` folder with per-environment configuration files
  * `lib/mix` (empty), for project-specific `mix` commands
  * `project_name.ex`, the application itself
  * `project_name/*`, where the project's code will go

The `modules` folder is left empty, with the exception of a 
`.placeholder` file.

### Module file structure

> ~/Sources/project_name/lib/project_name

```plaintext
project_name
└── modules
    └── sample
        ├── instance.ex
        ├── module.ex
        ├── modules
        │   └── ... # sub modules
        ├── schema.ext
        ├── service.ex
        └── supervisor.ex
```

Modules contain one source file per parts (the module, its service,
the instance supervisor and the instance itself). It can also optionally
contain:

  * a `modules` folder, containing sub-modules that will be started 
    as part of this module's supervision tree
  * `schema.ext` files

Modules can be nested as deep as desired, and nested modules have the same
structure as described here. They are to be monitored by the parent module.

`schema.ext` are reserved files that are to be used by either message or connector
modules; they should define each message's schema and the RPC endpoints (if any
are defined).

The extension used should reflect the content of the file. For instance, schema
files may be named as follow:

  - schema.proto
  - schema.thrift
  - schema.json
  - schema.avsc

And so on.

Modules can be generated using the `mix rak.gen.module` command.

## Group

  - Interface
  - Usability
  - Configurability

## Assumptions

Projects may greatly vary in complexity and customization; the file structure 
needs to be standardized both in arboresence and in name convention so to be able
to quickly identify which parts are standard structure in Rak, and which ones are not.

## Constraints

The project structure should be able to accomodate for future additions
to the framework, such as integration with serialization tools and code 
generation tools. For now, the example cases that were pondered on include:

  1. Integration with Protobuf, Thrift, JSON Schema, etc.
  2. Code generation of client-side APIs
  3. Generating code from static files (master data, etc)

In the first case, there should be a relatively simple but standard
way of defining schemas, while in the second we simply need to
be non-obstructive.

## Positions

### Module file structure

#### Single file

Put all the code in a single file:

```elixir
defmodule MyApp.MyModule do
  use Rak.Module

  defmodule Supervisor, do: use Rak.Module.Supervisor
  
  defmodule Service do
    schema "...."

    # ... 
  end

  defmodule Instance do
    # ...   
  end
end

#### Multiple files

Break down each actual modules into its own file:

```plaintext
project_name
└── modules
    └── sample
        ├── instance.ex
        ├── module.ex
        ├── modules
        │   └── ... # sub modules
        ├── service.ex
        └── supervisor.ex
```

### Schema

#### Inlined schemas

```elixir
defmodule Service do
    schema 
      protobuf: """
      """,
      avro: """
      """

    # ... 
  end
end
```

Schema could be broken down in parts so that relevant parts would
be stuck closer to the related code:

```elixir
defmodule Service do
    schema 
      protobuf: """
      """,
      avro: """
      """

    # Some code

    schema protobuf: """
    """
    message something %{} do
      # ...
    end
  end
end
```

#### Contract files

```plaintext
project_name
└── modules
    └── sample
        ├── schema.proto
        └── schema.avsc
```

Schema are in external files; the file extension determines the
associated message module.

## Argument

### Module file structure

Single files are quite elegant-looking, but the reality is that code is more often than
not required to grow in size. This means that it is more than likely that files
would become quite sizeable over time.

Additionally, forcing the creation of a folder for modules also has 
the benefit of providing a base compartimentalization of code; if modules
were stored in single files, adding schemas, submodules  or simply additional 
helper code would remain a question to be answered by end-users.

Angular 4/5 and Phoenix both have a cli to generate the modules; this should help
dealing with the additional boilerplate. In most cases, the files will be
almost empty, which should make it easy enough for developers not
familiar with Rak to scan through files and figure out which ones host code that
is relevant to them.

### Schema

Inlined schema would most likely bloat the code file itself (especially in cases
where `@doc` is religiously used). There is the concern that readability would be 
impacted.

Another concern is regarding "raw" third-party integration; by keeping the schema
files externalized, it remains quite simple to siply use them to generate code
(using the format's native tooling). 

Finally, externalized files can more easily act as contracts; that is, client developers
can simply check the schema file without having to scan through code, and see
clearly what the API will be.

## Implications

Since projects will be instanciated through a CLI interface, a command name
convention will be required.

The relationship between schema files and message modules will need to be
standardized; ideally, we will want message modules to not only use the
schema for serialization and deserialization, but also for sanity checking
during a server's startup sequence and for client code generation.

## Scheduled release

1.0.0

## Notes

No additional notes.
