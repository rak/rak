use Mix.Config

config :logger, :console,
  format: "\e[7;2m$time/$level\e[27;22m\e[1m $message\n\e[2m$metadata\n",
  metadata: :all

config :consul, 
  host: "127.0.0.1",
  port: 1234