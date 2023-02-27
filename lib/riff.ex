defmodule RIFF do
  require Integer

  @moduledoc """
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
  """

  @type chunk() :: simple_chunk() | chunk_with_sub_chunks()

  @type simple_chunk() :: %RIFF.Chunk{
    id: binary(),
    size: integer(),
    data: binary(),
  }

  @type chunk_with_sub_chunks() :: %RIFF.ChunkWithSubChunks{
    id: binary(),
    size: integer(),
    format: binary(),
    sub_chunks: list(chunk()),
  }

  defmodule Chunk do
    defstruct id: nil, size: 0, data: <<>>
  end

  defmodule ChunkWithSubChunks do
    defstruct id: nil, size: 0, format: <<>>, sub_chunks: []
  end

  @spec parse(binary()) :: chunk_with_sub_chunks()
  def parse(buffer) do
    <<id :: binary-size(4), size :: unsigned-little-size(32), format :: binary-size(4), rest::binary>> = buffer
    %ChunkWithSubChunks{
      id: id,
      size: size,
      format: format,
      sub_chunks: parse_sub_chunks(rest),
    }
  end

  @spec parse_sub_chunks(binary()) :: list(chunk())
  defp parse_sub_chunks(buffer) do
    <<id :: binary-size(4), size :: unsigned-little-size(32), rest :: binary>> = buffer
    if id == "LIST" do
      <<format :: binary-size(4), list_rest :: binary>> = rest
      [%ChunkWithSubChunks{
        id: id,
        size: size,
        format: format,
        sub_chunks: parse_sub_chunks(list_rest),
      }]
    else
      <<chunk_data::binary-size(size), another_chunk :: binary>> = rest
      current_chunk =  %Chunk{
        id: id,
        size: size,
        data: chunk_data,
      }
      another_chunk = cond do
        Integer.is_even(size) ->
          another_chunk
        byte_size(another_chunk) > 0 ->
          <<_ :: binary-size(1), rest :: binary>> = another_chunk
          rest
        true ->
          <<>>
      end
      if byte_size(another_chunk) > 8 do
        [current_chunk | parse_sub_chunks(another_chunk)]
      else
        [current_chunk]
      end
    end
  end

  @spec find_chunk(chunk_with_sub_chunks(), binary()) :: chunk()
  def find_chunk(%{ sub_chunks: chunks }, chunk_id) do
    Enum.find(chunks, fn %{id: id} -> id == chunk_id end)
  end

  @spec replace_sub_chunk(chunk_with_sub_chunks(), chunk()) :: chunk_with_sub_chunks()
  def replace_sub_chunk(parsed, new_sub_chunk) do
    index = Enum.find_index(parsed.sub_chunks, fn %{id: id} -> id == new_sub_chunk.id end)
    %{parsed | sub_chunks: List.replace_at(parsed.sub_chunks, index, new_sub_chunk)}
  end

  @spec encode(chunk_with_sub_chunks()) :: binary()
  def encode(parsed) do
    %{ id: id, size: size, format: format, sub_chunks: sub_chunks } = parsed
    rest_binary = Enum.reduce(sub_chunks, <<>>, fn x, acc -> acc <> encode_sub_chunk(x) end)
    <<id :: binary, size :: unsigned-little-size(32), format :: binary, rest_binary :: binary>>
  end

  @spec encode_sub_chunk(chunk()) :: binary()
  defp encode_sub_chunk(sub_chunk) do
    %{ id: id, size: size } = sub_chunk
    if id == "LIST" do
      encode(sub_chunk)
    else
      %{ data: data } = sub_chunk
      if Integer.is_even(byte_size(data)) do
        << id :: binary, size :: unsigned-little-size(32), data :: binary >>
      else
        << id :: binary, size :: unsigned-little-size(32), data :: binary, 0 :: size(8) >>
      end
    end
  end
end
