# RIFF

This is an Elixir module for reading and writing [RIFF](https://en.wikipedia.org/wiki/Resource_Interchange_File_Format) files.

## Example

```
> riff = File.read!("foo.webp")
<<82, 73, 70, 70, 192, 199 ...>>

> parsed = RIFF.parse(riff)
%RIFF.ChunkWithSubChunks{
  id: "RIFF",
  size: 51136,
  format: "WEBP",
  sub_chunks: [
    %RIFF.Chunk{
      id: "VP8L",
      size: 51123,
      data: <<47 ...>>
    }
  ]
}

> RIFF.find_chunk(parsed, "VP8L")
%RIFF.Chunk{
  id: "VP8L",
  size: 51123,
  data: <<47 ...>>
}

> data = RIFF.encode(parsed)
<<82, 73, 70, 70, 192, 199 ...>>
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `riff` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:riff, "~> 0.1.0"}
  ]
end
```

Documentation can be found at <https://hexdocs.pm/riff/RIFF.html>.
