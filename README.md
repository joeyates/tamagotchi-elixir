# tamagotchi-elixir

An implementation of a Tamagotchi 'electronic pet' in Elixir.

# Development

## Run

```
elixir tamagotchi.exs
```

# Release

## Compile

```
mix escript.build
```

## Run

```
./tamagotchi
```

# TODO

* limit state changes:
  * don't go over a max limit,
  * die under a minimum,
* use a GUI/curses library.
