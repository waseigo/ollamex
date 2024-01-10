<img src="./assets/ollamex_logo.png" width="100" height="100">

# Ollamex

An Elixir wrapper of [ollama](https://ollama.ai/)'s REST API with a few niceties built-in, such as dealing with endless LLM repetitions through a timeout.

Ollamex is written based on the [ollama REST API documentation](https://github.com/jmorganca/ollama/blob/main/docs/api.md) for the following endpoints:

* [List Local Models](https://github.com/jmorganca/ollama/blob/main/docs/api.md#list-local-models)
* [Generate a completion](https://github.com/jmorganca/ollama/blob/main/docs/api.md#generate-a-completion)
* [Generate a chat completion](https://github.com/jmorganca/ollama/blob/main/docs/api.md#generate-a-chat-completion)


## Installation

The package is [available in Hex](https://hex.pm/packages/ollamex) and can be installed by adding `ollamex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ollamex, "~> 0.1.0"}
  ]
end
```

## Documentation 
The docs can be found at <https://hexdocs.pm/ollamex>.

## Homepage
The homepage of Ollamex can be found at [overbring.com](https://overbring.com/software/ollamex).
