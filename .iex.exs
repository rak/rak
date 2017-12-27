{ platform, _ } = :os.type
{ loaded, _ } = Code.ensure_loaded(Elixir.Rak)

if loaded != :error  do
  if platform == :win32 do
    IO.puts IO.ANSI.magenta <> """

      ██████╗  █████╗ ██╗  ██╗
      ██╔══██╗██╔══██╗██║ ██╔╝
      ██████╔╝███████║█████╔╝
      ██╔══██╗██╔══██║██╔═██╗
      ██║  ██║██║  ██║██║  ██╗
      ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝

    """ <>
    IO.ANSI.cyan() <>
    "  version: " <>
    IO.ANSI.yellow() <>
    Rak.version <> """

    """
    IEx.configure(
      default_prompt: IO.ANSI.magenta <>
      "/dev/" <>
      IO.ANSI.cyan <>
      "Rak" <>
      IO.ANSI.white <>
      IO.ANSI.faint <>
      ">" <>
      IO.ANSI.reset
    )
  else
    IO.puts IO.ANSI.magenta() <> """

      ▄████████    ▄████████    ▄█   ▄█▄
      ███    ███   ███    ███   ███ ▄███▀
      ███    ███   ███    ███   ███▐██▀
     ▄███▄▄▄▄██▀   ███    ███  ▄█████▀
     ▀███▀▀▀▀▀    ▀███████████ ▀█████▄
     ▀███████████  ███    ███   ███▐██▄
      ███    ███   ███    ███   ███ ▀███▄
      ███    ███   ███    █▀    ███   ▀█▀
      ███    ███                ▀

    """ <>
    IO.ANSI.cyan() <>
    "  version: " <>
    IO.ANSI.yellow() <>
    Rak.version <> """

    """

    IEx.configure(
      # default_prompt: "\e[32mΔ\e[36mRακ\e[1;30m>\e[0m"
      default_prompt: IO.ANSI.magenta <>
        "δ" <>
        IO.ANSI.cyan <>
        "Rακ" <>
        IO.ANSI.white <>
        IO.ANSI.faint <>
        ">" <>
        IO.ANSI.reset
    )
  end
end
