# Identicon Generator

Generate identicon image from an input string

## What is Identicon?

An identicon is a visual representation of a hash value. It's a type of avatar that protects the user's privacy.

## Demo

Inside your parent folder terminal:

- Install the dependencies

```bash
mix deps.get
```

- Run elixir interactive shell

```bash
iex -S mix
```

- Generate the image

```iex
Identicon.main("adi")
```

## Result

the generated image will be saved inside parent folder

<img src="https://github.com/NyomanAdiwinanda/Identicon-Generator/blob/main/adi.png?raw=true" width="200">

## Docs

run `mix docs` and go to `doc/index.html` to see the project documentation

## Tests

run `mix test` to run testing
