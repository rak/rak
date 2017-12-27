defmodule Rak.App do
    # This list of components group documents in code
    # what component groups can be specified, and in which order
    # they will be started
    @components [
        metrics:    "Metrics system",
        service:    "Top-level application service",
        module:     "Application module",
        session:    "Session module",
        discovery:  "Discovery and clustering (optional)",
        connector:  "Network connector for clients to connect to the server",
    ]

    # Stringify the list of supported component groups
    # for use within the documentation
    @componentsdoc @components
        |> inspect
        |> String.replace(", ", ",\n\t")
        |> String.replace("[", "[\n\t")
        |> String.replace("]", "\n]")

    @moduledoc """
    Rak Game Server Maker

    The top level module is used to define how your server will be composed.
    In here, we define which services to use, and how they will connect to each other.

    > lib/my_app.ex

    ```elixir
    defmodule MyApp do
        use Rak.App,
            metrics: Rak.Metrics.Prometheus,
            service: MyApp.Service,
            module: :auto,
            discovery: Rak.Discovery.Consul,
            connector: [
                module: Rak.Connector.Web,
                message: Rak.Message.Raw,
                session: Rak.Session.Basic
            ]
    end
    ```

    Components groups are started in the following order:

    ```elixir
    #{@componentsdoc}
    ```
    While components groups are  in a fixed order, and
    components within a group will be started in the
    order they are provided in.

    You may also specify multiple entries for each components,
    or remove them if you do not use them.

    > lib/my_app.ex

    ```elixir
    defmodule MyApp do
        use Rak.App,
            service: MyApp.Service
            metrics: Rak.Metrics.Prometheus,
            metrics: Rak.Metrics.CollectD,
    end
    ```

    For instance, in this case `metrics` components will be started before
    the `service` component, but the Prometheus `metrics` component will always
    start before the `CollectD` one.

    `module: :auto` is a wildcard configuration entry that lets
    Rak know to load all top-level modules automatically. Note that
    `module: :auto` can be used alongside a set module load order:

    > lib/my_app.ex

    ```elixir
    defmodule MyApp do
        use Rak.App,
            module: MyApp.LoadThisFirstModule,
            module: MyApp.LoadThisSecondModule,
            module: :auto,
            module: MyApp.LoadThisLastModule
    end
    ```

    You may want to configure which modules to start depending
    on the environment you are running. For instance, you may not
    want to start the discovery service when developing locally. In
    such cases, you may move the configuration to your `config/config.exs`
    and override it depending on the environment.

    > lib/my_app.ex

    ```elixir
    defmodule MyApp do
        use Rak.App
    end
    ```

    > config/config.exs

    ```elixir
    use Mix.Config

    config MyApp,
        rak: [
            metrics: Rak.Metrics.Prometheus,
            service: MyApp.Service,
            module: :auto,
            discovery: Rak.Discovery.Consul,
            connector: [
                module: Rak.Connector.Web,
                message: Rak.Message.Raw,
                session: Rak.Session.Basic
            ]
        ]
    """

    # The `__using__` macro will set the module
    # as an application and create a Supervisor submodule
    # that will be used to supervise the application's
    # components
    #
    # If no configuration is provided, we attempt to load
    # the configuration using Application.get_env
    defmacro __using__([]) do
        config = quote do
            Application.get_env(__MODULE__, :rak, [])
        end
        setup config
    end
    defmacro __using__(config), do: setup(config)

    # This function is injected by the `__using__` macro
    # and serves the goal of converting the configuration
    # into an ordered list of children specification to be
    # used by the application's top-level supervisor during
    # initialization.
    @doc false
    def config_children(config, args) do
      app_module = args[:app_module]
      app_modules = get_app_modules(config, app_module)
      session_modules = get_session_modules(config)

      config = Keyword.drop(config, [:module])
      config = app_modules
          ++ session_modules
          ++ config

      unquote(@components)
        |> Keyword.keys
        |> Enum.reduce([], fn(component, children) ->
          component_config = config
            |> Keyword.get_values(component)
            |> Enum.map(fn (config) ->
                get_child_spec(component, config)
            end)

          children ++ component_config
        end)
        |> List.flatten
        |> Enum.uniq
    end

    defp setup(config), do: [
        get_application_definition(),
        get_supervisor_definition(config)
    ]

    # Define the application start behavior
    defp get_application_definition() do
      quote do
        use Application

        @doc """
        Start
        """
        def start({:takeover, node}, _) do
          raise Rak.Exception,
            message: "Takeover is not supported",
            details: "Ref: https://hexdocs.pm/elixir/Application.html#callbacks"
        end

        def start({:failover, node}, _) do
          raise Rak.Exception,
            message: "Failover is not supported",
            details: "Ref: https://hexdocs.pm/elixir/Application.html#callbacks"
        end

        def start(:normal, cli_args) do
          args = [
            app_module: __MODULE__,
            cli: cli_args
          ]

          Supervisor.start_link(__MODULE__.Supervisor, args, name: __MODULE__.Supervisor)
        end

        def stop(pid) do
          Supervisor.stop(pid, :normal, 5000)
        end

        # The order is reversed to show the processes
        # in the order they were started
        def children, do: __MODULE__.Supervisor
          |> Supervisor.which_children
          |> Enum.reverse
      end
    end

    # Define the supervisor as a sub-module of the application
    # this module definition will be placed within the
    # parent module's code: for instance, the supervisor
    # for MyApp will be under MyApp.Supervisor
    defp get_supervisor_definition(config) do
      quote do
        defmodule Supervisor do
          @moduledoc false
          use Elixir.Supervisor

          def init(args) do
            unquote(config)
              |> Rak.App.config_children(args)
              |> Supervisor.init(strategy: :one_for_one)
          end
        end
      end
    end

    # Scan the list of configured modules; if `module: :auto`
    # is found, the list of modules is split into two, and a
    # runtime module autoloader is injected to replace the
    # `module: :auto` configuration
    defp get_app_modules(config, app_module) do
        modules = config
            |> Keyword.get_values(:module)

        auto_index = Enum.find_index(modules, fn (val) ->
            val == :auto
        end)

        if auto_index do
            {pre, [_|post]} = Enum.split(modules, auto_index)
            autoloaded_modules = app_module
              |> autoload_modules
              |> Enum.filter(fn(module) -> !Enum.member?(pre, module) end)
              |> Enum.filter(fn(module) -> !Enum.member?(post, module) end)

            pre ++
            autoloaded_modules ++
            post
              |> Enum.map(fn(module) -> {:module, module} end)
        else
            modules
        end
    end

    # Extract the list of session modules to load
    # from all connector configurations
    defp get_session_modules(config) do
        config
            |> Keyword.get_values(:connector)
            |> Stream.uniq
            |> Enum.map(&get_session_module/1)
    end

    # Extract the module from a session module
    defp get_session_module(config), do: get_session_module(config[:module], config[:session])
    defp get_session_module(connector, nil) do
      raise Rak.Exception,
          message: "Missing session module for connector #{connector}",
          details: "Without a session module, connections cannot be handled"
    end
    defp get_session_module(_, session), do: { :session, session }


    # Get the child spec for a given module
    # In most case, we simply want to return the module's
    # child_spec call, but in cases such as connectors, we
    # will also want to specify configuration elements (such as
    # message parser and session module)
    defp get_child_spec(:connector, config) do
        module = config[:module]
        config = Keyword.drop(config, [:module])

        {module, config}
    end

    defp get_child_spec(_, module) do
        {module, []}
    end

    # This function is injected by the `__using__` macro
    # when `module: :auto` is present, and is called at runtime
    # to list modules to load and add them to the list of children
    # of the top-level supervisor
    @doc false
    defp autoload_modules(app_module) do
      app_module_name = Atom.to_string(app_module)
      app_module_depth = app_module
        |> Module.split
        |> length

      :code.all_loaded
        |> Stream.map(fn({ module, _ }) ->
            module_name = Atom.to_string(module)
            { module, module_name }
        end)
        |> Stream.filter(fn({ _, module_name }) ->
            String.starts_with?(module_name, app_module_name)
        end)
        |> Stream.filter(fn({ _, module_name }) ->
          module_depth = module_name
              |> Module.split
              |> length

          module_depth == app_module_depth + 1
        end)
        |> Stream.filter(fn({ module, _ }) ->
          attributes = module.__info__(:exports)
          Keyword.has_key?(attributes, :rak_module?)
        end)
        |> Enum.map(fn ({ module, _}) -> module end)
  end
end
