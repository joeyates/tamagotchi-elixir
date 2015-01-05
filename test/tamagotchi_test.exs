defmodule TamagotchiTest do
  use ExUnit.Case

  setup do
    pid = spawn(Tamagotchi, :start, [self()])
    {:ok, [pid: pid]}
  end

  test "it reports status every tick", context do
    send(context[:pid], {:tick})
    assert_receive {:status, _}
  end

  test "sleep puts it to sleep", context do
    send(context[:pid], {:sleep})
    receive do
      {:status, status} ->
        assert Regex.match?(~r/asleep/, status)
    end
  end

  test "wake wakes it up, if it's asleep", context do
    send(context[:pid], {:sleep})
    receive do {:status, _} -> end
    send(context[:pid], {:wake})
    receive do
      {:status, status} ->
        assert Regex.match?(~r/awake/, status)
    end
  end

  test "when awake, it loses 10 energy every tick", context do
    send(context[:pid], {:tick})
    receive do
      {:status, status} ->
        assert Regex.match?(~r/energy: 990/, status)
    end
  end

  test "when asleep, it gains 10 energy every tick", context do
    send(context[:pid], {:sleep})
    receive do {:status, _} -> end
    send(context[:pid], {:tick})
    receive do
      {:status, status} ->
        assert Regex.match?(~r/energy: 1010/, status)
    end
  end

  test "when awake, it loses 10 stomach every tick", context do
    send(context[:pid], {:tick})
    receive do
      {:status, status} ->
        assert Regex.match?(~r/stomach: 990/, status)
    end
  end

  test "when asleep, it loses 5 stomach every tick", context do
    send(context[:pid], {:sleep})
    receive do {:status, _} -> end
    send(context[:pid], {:tick})
    receive do
      {:status, status} ->
        assert Regex.match?(~r/stomach: 995/, status)
    end
  end

  test "when awake, it loses 10 hygiene every tick", context do
    send(context[:pid], {:tick})
    receive do
      {:status, status} ->
        assert Regex.match?(~r/hygiene: 990/, status)
    end
  end

  test "when asleep, it loses 1 hygiene every tick", context do
    send(context[:pid], {:sleep})
    receive do {:status, _} -> end
    send(context[:pid], {:tick})
    receive do
      {:status, status} ->
        assert Regex.match?(~r/hygiene: 999/, status)
    end
  end

  test "feeding adds 750 to stomach", context do
    send(context[:pid], {:feed})
    receive do
      {:status, status} ->
        assert Regex.match?(~r/stomach: 1750/, status)
    end
  end

  test "cleaning reset hygiene", context do
    send(context[:pid], {:feed})
    receive do
      {:status, status} ->
        assert Regex.match?(~r/hygiene: 1000/, status)
    end
  end

  test "'quit' stops it running", context do
    send(context[:pid], {:quit})
    assert_receive {:quit}
  end
end
