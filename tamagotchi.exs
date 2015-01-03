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
    run(game, hatch())
  end

  defp hatch do
    {:ok, agent} = Agent.start_link fn ->
      %{state: :awake, energy: 1000, stomach: 1000, hygiene: 1000}
    end
    agent
  end

  defp run(game, agent) do
    receive do
      {:tick} ->
        change(agent, :energy, -10)
      {:feed} ->
        case get(agent, :state) do
          :awake ->
            change(agent, :energy, 750)
          _ ->
            IO.puts "I can't eat while I'm asleep"
        end
      {:sleep} ->
        state = get(agent, :state)
        case state do
          :awake ->
            set(agent, :state, :asleep)
          :asleep ->
            IO.puts "I'm already asleep!"
          _ ->
            IO.puts "I'm #{state}"
        end
      {:wake} ->
        state = get(agent, :state)
        case state do
          :asleep ->
            set(agent, :state, :awake)
          :awake ->
            IO.puts "I'm already awake"
           _ ->
            IO.puts "I'm #{state}"
         end
      {:quit} ->
        set(agent, :state, :dying)
        IO.puts "Aaaargh, you killed me!"
        send(game, {:quit})
    end
    report(game, agent)
    state = get(agent, :state)
    unless state == :dying do
      run(game, agent)
    end
  end

  defp report(game, agent) do
    state = get(agent, :state)
    energy = get(agent, :energy)
    stomach = get(agent, :stomach)
    hygiene = get(agent, :hygiene)
    send(game, {:status, state, energy, stomach, hygiene})
  end

  defp get(agent, key) do
    Agent.get(agent, fn state -> Map.get(state, key) end)
  end

  defp set(agent, key, value) do
    Agent.cast(agent, fn state -> Map.put(state, key, value) end)
  end

  defp change(agent, key, amount) do
    Agent.cast(agent, fn state ->
      val = Map.get(state, key)
      Map.put(state, key, val + amount)
    end)
  end
end

defmodule Ticker do
  def start(target) do
    run(target)
  end

  defp run(target) do
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
