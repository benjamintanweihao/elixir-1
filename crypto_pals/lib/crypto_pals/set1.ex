defmodule CryptoPals.Set1 do

  use Bitwise
  require Integer

  @relative_freqs [
    {?e, 13}, {?t, 9}, {?a, 8}, {?o, 8}, {?i, 7}, {?n, 7},
    {?s,  6}, {?h, 6}, {?r, 6}, {?d, 4}, {?l, 4}, {?c, 3},
    {?u,  3}, {?m, 2}, {?w, 2}, {?f, 2}, {?g, 2}, {?y, 2},
    {?p,  2}, {?b, 2}, {?v, 1}, {?k, 1}, {?j, 1}, {?x, 1},
    {?q, 1}, {?z, 1}
  ]

  @doc """
  Converts a hex encoded byte string into a base64 string.

  ## Examples

      iex> CryptoPals.Set1.hex_to_base64("deadbeef")
      "w57CrcK+w68="
      iex> CryptoPals.Set1.hex_to_base64("49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d")
      "SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t"
  """
  def hex_to_base64(s) do
    s |> hex_to_bytes |> Base.encode64
  end

  # ================ 1 ================

  @doc """
  Converts a hex encoded byte string into a string where each character is
  the eight-bit character corresponding to the two-digit hex number.

  ## Examples

      iex> CryptoPals.Set1.hex_to_bytes("deadbeef")
      "Þ­¾ï"
  """
  def hex_to_bytes(s), do: hex_to_bytes(s, [])

  defp hex_to_bytes("", out) do
    out |> Enum.reverse |> to_string
  end

  defp hex_to_bytes(<<b0, b1>> <> rest, out) do
    n = [b0, b1] |> to_string |> String.to_integer(16)
    hex_to_bytes(rest, [n | out])
  end

  # ================ 2 ================

  @doc """
  Takes two strings which are hex encoded byte strings and returns the XOR
  of the two numbers as an integer.

  ## Examples

  The example output here shows hex values, but the values printed in IEx
  will be decimal.

      iex> CryptoPals.Set1.fixed_xor("0123", "0101")
      0x0022
      iex> CryptoPals.Set1.fixed_xor("1c0111001f010100061a024b53535009181c",
      ...>                           "686974207468652062756c6c277320657965")
      0x746865206b696420646f6e277420706c6179
  """
  def fixed_xor(s0, s1) do
    n0 = String.to_integer(s0, 16)
    n1 = String.to_integer(s1, 16)
    n0 ^^^ n1
  end

  # ================ 3 ================

  @doc """
  Finds best (most "English") match for hard-coded string that has been
  XOR-ed with a mystery byte.
  """
  def single_byte_xor_cipher do
    s = "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"
    single_byte_xor_cipher(s)
  end

  @doc """
  Finds best (most "English") match for string s that has been XOR-ed with a
  mystery byte and returns the string.

  ## Examples
      iex> CryptoPals.Set1.single_byte_xor_cipher("1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736")
      "Cooking MC's like a pound of bacon"
  """ # ' <= work around Emacs font lock bug
  def single_byte_xor_cipher(s) do
    (0..255)
      |> Enum.map(&(single_byte_xor_cipher(s, &1)))
      |> Enum.max_by(&englishness/1)
  end

  @doc """
  Calculate a number that determines how likely that the given string is
  english text. Higher numbers are better. Letters get two points plus a
  bonus for how popular they are ("etaion shrdlu"); whitespace, punctuation,
  and numbers get one.

  ## Examples

      iex> CryptoPals.Set1.englishness("abc")
      19/3
      iex> CryptoPals.Set1.englishness("ABC")
      19/3
      iex> CryptoPals.Set1.englishness("a?")
      11/2
      iex> CryptoPals.Set1.englishness("This is a test. Fun? Yes!")
      161/25
      iex> CryptoPals.Set1.englishness("Level 42")
      48/8
      iex> CryptoPals.Set1.englishness("thê")
      18/3

  """
  def englishness(s), do: englishness(s, {String.length(s), 0})

  defp englishness(<<>>, {slen, sum}), do: sum / slen
  defp englishness(<<c :: utf8, t :: binary>>, {slen, sum}) when c in ?a .. ?z do
    englishness(t, {slen, sum + 2 + freq_bonus(c)})
  end
  defp englishness(<<c :: utf8, t :: binary>>, {slen, sum}) when c in ?A .. ?Z do
    englishness(t, {slen, sum + 2 + freq_bonus(c - ?A + ?a)})
  end
  defp englishness(<<c :: utf8, t :: binary>>, {slen, sum})
    when c == ?\s or
      c in ?0 .. ?9 or
      c in [?., ?,, ?!, ??, ?;, ?;, ?(, ?)] \
  do
    englishness(t, {slen, sum + 1})
  end
  defp englishness(<<_ :: utf8, t :: binary>>, {slen, sum}), do: englishness(t, {slen, sum-1})

  defp freq_bonus(c) when c in ?a .. ?z do
    {_, freq} = List.keyfind(@relative_freqs, c, 0)
    freq
  end
  defp freq_bonus(_), do: 0

  # Apply byte as XOR key to hex encoded string s and return string.
  defp single_byte_xor_cipher(s, byte) do
    num_bytes = div String.length(s), 2
    byte
      |> byte_duped_for_xor(num_bytes)
      |> fixed_xor(s)
      |> even_len_hex_str
      |> hex_to_bytes
  end

  @doc """
  Returns a hex encoded byte string with byte repeated num_bytes times.

  ## Example

      iex> CryptoPals.Set1.byte_duped_for_xor(0, 3)
      "000000"
      iex> CryptoPals.Set1.byte_duped_for_xor(0xfa, 3)
      "FAFAFA"
  """
  def byte_duped_for_xor(byte, num_bytes) do
    byte
      |> even_len_hex_str
      |> String.duplicate(num_bytes)
  end

  @doc """
  Turn an int into an even-length base 16 string. A zero is prepended if
  needed to make the string length even.

  ## Examples

      iex> CryptoPals.Set1.even_len_hex_str(0)
      "00"
      iex> CryptoPals.Set1.even_len_hex_str(15)
      "0F"
      iex> CryptoPals.Set1.even_len_hex_str(127)
      "7F"
      iex> CryptoPals.Set1.even_len_hex_str(128)
      "80"
      iex> CryptoPals.Set1.even_len_hex_str(0xdeadbeef)
      "DEADBEEF"
  """
  def even_len_hex_str(n) do
    n
      |> Integer.to_string(16)
      |> leading_zero_if_odd_length
  end
    
  @doc """
  If s has odd length, a new string is returned by prepending a zero to s.

  ## Examples

      iex> CryptoPals.Set1.leading_zero_if_odd_length(    "")
      ""
      iex> CryptoPals.Set1.leading_zero_if_odd_length(   "d")
      "0d"
      iex> CryptoPals.Set1.leading_zero_if_odd_length(  "cd")
      "cd"
      iex> CryptoPals.Set1.leading_zero_if_odd_length( "bcd")
      "0bcd"
      iex> CryptoPals.Set1.leading_zero_if_odd_length("abcd")
      "abcd"
  """
  def leading_zero_if_odd_length(s) do
    if Integer.even?(String.length(s)) do
      s
    else
      "0#{s}"
    end
  end

  # ================ 4 ================

  @doc """
  Find which string has been XOR-ed with a single byte in a file.

  ## Examples

      Commented out, because this takes around 10 seconds to run. It works,
      though.

      # iex> CryptoPals.Set1.find_xored_in_file("data/4.txt")
      # "Now that the party is jumping"

  """
  def find_xored_in_file(path) do
    File.stream!(path)
      |> Stream.map(&best_xored/1)
      |> Enum.max_by(&englishness/1)
      |> String.rstrip
  end

  defp best_xored(line) do
    line
      |> String.rstrip
      |> single_byte_xor_cipher
  end

  # ================ 5 ================

  @doc """
  XORs a string with a key, which may be shorter than the string.

  ## Examples

      iex> CryptoPals.Set1.repeating_key_xor("Burning 'em, if you ain't quick and nimble\\nI go crazy when I hear a cymbal", "ICE")
      "0B3637272A2B2E63622C2E69692A23693A2A3C6324202D623D63343C2A26226324272765272A282B2F20430A652E2C652A3124333A653E2B2027630C692B20283165286326302E27282F"
  """
  def repeating_key_xor(plaintext, key) do
    key = String.duplicate(key, div(String.length(plaintext), String.length(key)) + 1)
    Stream.zip(String.to_char_list(plaintext), String.to_char_list(key))
      |> Stream.map(fn({b0, b1}) -> byte_xor_16(b0, b1) end)
      |> Enum.join
  end

  # Takes two bytes, XORs them, and turns the result into a two-character
  # hex string.
  defp byte_xor_16(b0, b1) do
      b0 ^^^ b1
        |> even_len_hex_str
  end

  # ================ 6 ================

  def break_repeating_key_xor, do: break_repeating_key_xor("data/6.txt")

  @doc """
  Break repeating-key XOR in a file.

  ## Examples

      # iex> CryptoPals.Set1.break_repeating_key_xor("data/6.txt")
      # "???"

  """
  def break_repeating_key_xor(path) do
    data = File.read!(path)
      |> String.replace("\n", "")
      |> Base.decode64!
      |> String.to_char_list
    keysize = likely_keysize(data)
    translated_blocks = data |> Enum.chunk(keysize) |> translate_blocks
    key_bytes = translated_blocks
      |> Enum.map(&single_byte_xor_cipher_byte/1)
      |> Enum.map(fn({cipher_byte, _englishness, _s}) ->
                    IO.puts _englishness
                    IO.puts _s
                    cipher_byte
                  end)
    key = to_string(key_bytes)
    IO.puts key                 # DEBUG

    to_string(data)
      |> repeating_key_xor(key)
      |> hex_to_bytes
  end

  @doc """
  Finds best (most "English") match for byte list that has been XOR-ed with
  a mystery byte and returns a typle containing the byte and the best match
  string.

  ## Examples
      iex> CryptoPals.Set1.single_byte_xor_cipher_byte(
      ...>   "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"
      ...>     |> CryptoPals.Set1.hex_to_bytes
      ...>     |> String.to_char_list)
      {88, 201/34, "Cooking MC's like a pound of bacon"}
  """ # ' <= work around Emacs font lock bug
  def single_byte_xor_cipher_byte(s) do
    (0..255)
      |> Enum.reduce({0, 0, ""}, fn(byte, {_, e_englishness, _} = acc) ->
                                xored = s |> Enum.map(fn(c) -> c ^^^ byte end)
                                e = englishness(to_string(xored))
                                if e > e_englishness do
                                  {byte, e, to_string(xored)}
                                else
                                  acc
                                end
                     end)
  end

  @doc """
  Return the likely keysize of data. Try various key sizes. For each size,
  take the first two blocks and compute the Hamming distance between. The
  size that has the minimum distance is the likely keysize.
  """
  def likely_keysize(data) do
    (2..40)
      |> Enum.map(&(num_blocks_of_size(data, &1, 2)))
      |> Enum.min_by(fn([block0, block1]) ->
                       div(hamming_distance(block0, block1), length(block0))
                     end)
      |> hd
      |> length
  end

  @doc """
  Make a block that is the first byte of every block, and a block that is
  the second byte of every block, and so on.

  ## Examples

      iex> CryptoPals.Set1.translate_blocks([[1, 2, 3], [4, 5, 6]])
      [[1, 4], [2, 5], [3, 6]]
  """ 
  def translate_blocks(blocks), do: translate_blocks(blocks, [])

  defp translate_blocks([], translated), do: Enum.reverse(translated)
  defp translate_blocks([[]|_], translated), do: Enum.reverse(translated)
  defp translate_blocks(lists, translated) do
    # inefficient (goes through lists twice)
    heads = lists |> Enum.map(fn(l) -> hd(l) end)
    tails = lists |> Enum.map(fn(l) -> tl(l) end)
    translate_blocks(tails, [heads | translated])
  end

  @doc """
  Return a list of num_blocks chunks of data, each of the specified size.

  ## Examples

      iex> CryptoPals.Set1.num_blocks_of_size([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 3, 2)
      [[1, 2, 3], [4, 5, 6]]
  """
  def num_blocks_of_size(data, size, num_blocks) do
    data
      |> Enum.chunk(size)
      |> Enum.take(num_blocks)
  end

  @doc """
  Calculates the Hamming distance between two strings or char sets.

  ## Examples

      iex> CryptoPals.Set1.hamming_distance("this is a test", "wokka wokka!!!")
      37
      iex> CryptoPals.Set1.hamming_distance([1, 2, 3], [1, 2, 2])
      1
  """
  def hamming_distance(s0, s1) when is_binary(s0) and is_binary(s1) do
    hamming_distance(String.to_char_list(s0), String.to_char_list(s1))
  end

  def hamming_distance(s0, s1) when is_list(s0) and is_list(s1) do
    Enum.zip(s0, s1)
      |> Enum.map(fn({c0, c1}) -> c0 ^^^ c1 end)
      |> Enum.map(&count_one_bits/1)
      |> Enum.sum
  end

  def count_one_bits(n), do: count_one_bits(n, 0)

  defp count_one_bits(0, acc), do: acc
  defp count_one_bits(n, acc) when Integer.odd?(n), do: count_one_bits(n >>> 1, acc+1)
  defp count_one_bits(n, acc)                     , do: count_one_bits(n >>> 1, acc)

  # ================ helpers ================

  # defp debug(val) do
  #   if String.printable?(val) do
  #     IO.puts "#{val}"
  #   end
  #   val
  # end

end