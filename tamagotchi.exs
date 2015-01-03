defmodule Game do
  def start() do
    tamagotchi = spawn(Tamagotchi, :start, [self()])
    spawn(Ticker, :start, [tamagotchi])
    spawn(Owner, :start, [tamagotchi])
    listen
  end

  defp listen do
    receive do
      {:status, state, energy, stomach, hygiene} ->
        display(state, energy, stomach, hygiene)
        listen
      {:quit} ->
        IO.puts "Game over!"
    end
  end

  defp display(state, energy, stomach, hygiene) do
    IO.puts "Tamagotchi #{state} energy: #{energy}, stomach: #{stomach}, hygiene: #{hygiene}"
  end
end

defmodule Tamagotchi do
  def start(game) do
    run(game, :awake, 1000, 1000, 1000)
  end

  defp run(game, state, energy, stomach, hygiene) do
    continue = true
    receive do
      {:tick} ->
        energy = energy - 10
      {:feed} ->
        case state do
          :awake ->
            energy = energy + 750
          _ ->
            IO.puts "I can't eat while I'm asleep"
        end
      {:sleep} ->
        case state do
          :awake ->
            state = :asleep
          _ ->
            IO.puts "I'm already asleep!"
        end
      {:wake} ->
        case state do
          :asleep ->
            state = :awake
          _ ->
            IO.puts "I'm already awake"
        end
      {:quit} ->
        IO.puts "Aaaargh, you killed me!"
        send(game, {:quit})
        continue = false
    end
    if continue do
      send(game, {:status, state, energy, stomach, hygiene})
      run(game, state, energy, stomach, hygiene)
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
      "sleep" ->
        send(tamagotchi, {:sleep})
      "wake" ->
        send(tamagotchi, {:wake})
      "quit" ->
        send(tamagotchi, {:quit})
      _ ->
        IO.puts "unrecognised command: #{command}"
    end
    run(tamagotchi)
  end
end

Game.start
