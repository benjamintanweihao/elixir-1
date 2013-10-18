defrecord Event,
  symbol: :off,
  delta_time: 0,
  bytes: []                     # data bytes, including status byte

defrecord Track,
  name: "Unnamed",
  events: [] do

  def instrument(Track[events: nil]), do: ""
  def instrument(Track[events: []]),  do: ""
  def instrument(Track[events: list])  do
    Enum.find(list, Event[], &(&1.symbol == :instrument)).bytes
  end
end

defrecord Sequence,
  header: nil,
  conductor_track: nil,
  tracks: [] do

  def name(Sequence[conductor_track: nil]), do: ""
  def name(Sequence[conductor_track: Track[events: []]]),  do: ""
  def name(Sequence[conductor_track: Track[events: list]])  do
    Enum.find(list, Event[], &(&1.symbol == :seq_name)).bytes
  end

end
