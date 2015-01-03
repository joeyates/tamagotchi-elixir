defmodule Game do
  def start() do
    tamagotchi = spawn(Tamagotchi, :start, [self()])
    spawn(Ticker, :start, [tamagotchi])
    spawn(Owner, :start, [tamagotchi])
    listen
  end

  defp listen do
    receive do
      {:status, energy} ->
        display(energy)
        listen
      {:quit} ->
        IO.puts "Game over!"
    end
  end

  defp display(energy) do
    IO.puts "Tamagotchi energy: #{energy}"
  end
end

defmodule Tamagotchi do
  def start(game) do
    run(game, 1000)
  end

  defp run(game, energy) do
    continue = true
    receive do
      {:tick} ->
        energy = energy - 10
      {:feed} ->
        energy = energy + 750
      {:quit} ->
        IO.puts "Aaaargh, you killed me!"
        send(game, {:quit})
        continue = false
    end
    if continue do
      send(game, {:status, energy})
      run(game, energy)
    end
  end
end

defmodule Ticker do
  def start(target) do
    run(target)
  end

  def run(target) do
    Enum.to_list(Stream.timer(1000))
    send(target, {:tick})
    run(target)
  end
end

defmodule Owner do
  def start(tamagotchi) do
    run(tamagotchi)
  end

  defp run(tamagotchi) do
    command = String.rstrip(IO.gets(": "))
    case command do
      "feed" ->
        send(tamagotchi, {:feed})
      "quit" ->
        send(tamagotchi, {:quit})
      _ ->
        IO.puts "unrecognised command: #{command}"
    end
    run(tamagotchi)
  end
end

Game.start
