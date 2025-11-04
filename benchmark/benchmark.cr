require "../src/timezone_finder"

# Benchmark timezone lookups
# Run with: crystal run benchmark/benchmark.cr --release

# Test coordinates from around the world
test_coordinates = [
  {lat: 49.842957, lon: 24.031111, name: "Kyiv, Ukraine"},
  {lat: 40.71, lon: -74.00, name: "New York, USA"},
  {lat: 51.5074, lon: -0.1278, name: "London, UK"},
  {lat: 35.6762, lon: 139.6503, name: "Tokyo, Japan"},
  {lat: -33.8688, lon: 151.2093, name: "Sydney, Australia"},
  {lat: -23.5505, lon: -46.6333, name: "São Paulo, Brazil"},
  {lat: 55.7558, lon: 37.6173, name: "Moscow, Russia"},
  {lat: 28.6139, lon: 77.2090, name: "New Delhi, India"},
  {lat: 39.9042, lon: 116.4074, name: "Beijing, China"},
  {lat: -34.6037, lon: -58.3816, name: "Buenos Aires, Argentina"},
  {lat: 30.0444, lon: 31.2357, name: "Cairo, Egypt"},
  {lat: 1.3521, lon: 103.8198, name: "Singapore"},
  {lat: 52.5200, lon: 13.4050, name: "Berlin, Germany"},
  {lat: 48.8566, lon: 2.3522, name: "Paris, France"},
  {lat: 41.9028, lon: 12.4964, name: "Rome, Italy"},
  {lat: 37.7749, lon: -122.4194, name: "San Francisco, USA"},
  {lat: 25.2048, lon: 55.2708, name: "Dubai, UAE"},
  {lat: -22.9068, lon: -43.1729, name: "Rio de Janeiro, Brazil"},
  {lat: 59.9343, lon: 10.7161, name: "Oslo, Norway"},
  {lat: 64.8378, lon: -147.7164, name: "Fairbanks, Alaska"},
]

puts "Timezone Finder Benchmark"
puts "=" * 50
puts ""

# Benchmark: Initial load time
puts "1. Dataset Loading Time:"
start_time = Time.monotonic
TimezoneFinder.ensure_loaded
features = TimezoneFinder.features
load_time = Time.monotonic - start_time
puts "   Loaded #{features.size} timezone features in #{load_time.total_milliseconds.round(2)} ms"
puts ""

# Benchmark: Single lookup
puts "2. Single Lookup Performance:"
single_lookup_times = [] of Float64
test_coordinates.each do |coord|
  start_time = Time.monotonic
  tz = TimezoneFinder.lookup(coord[:lat], coord[:lon])
  elapsed = Time.monotonic - start_time
  single_lookup_times << elapsed.total_milliseconds
  puts "   #{coord[:name]}: #{tz.try(&.name) || "nil"} (#{elapsed.total_milliseconds.round(3)} ms)"
end
avg_single = single_lookup_times.sum / single_lookup_times.size
min_single = single_lookup_times.min
max_single = single_lookup_times.max
puts "   Average: #{avg_single.round(3)} ms"
puts "   Min: #{min_single.round(3)} ms"
puts "   Max: #{max_single.round(3)} ms"
puts ""

# Benchmark: Batch lookups (1000 lookups)
puts "3. Batch Lookup Performance (1000 lookups):"
iterations = 1000
start_time = Time.monotonic
iterations.times do |i|
  coord = test_coordinates[i % test_coordinates.size]
  TimezoneFinder.lookup(coord[:lat], coord[:lon])
end
batch_time = Time.monotonic - start_time
avg_batch = (batch_time.total_milliseconds / iterations)
throughput = (iterations / batch_time.total_seconds).round
puts "   #{iterations} lookups in #{batch_time.total_milliseconds.round(2)} ms"
puts "   Average per lookup: #{avg_batch.round(3)} ms"
puts "   Throughput: #{throughput} lookups/second"
puts ""

# Benchmark: Random coordinate lookups
puts "4. Random Coordinate Lookup Performance (1000 lookups):"
random_times = [] of Float64
start_time = Time.monotonic
1000.times do
  lat = rand(-90.0..90.0)
  lon = rand(-180.0..180.0)
  lookup_start = Time.monotonic
  TimezoneFinder.lookup(lat, lon)
  random_times << (Time.monotonic - lookup_start).total_milliseconds
end
random_total = Time.monotonic - start_time
avg_random = random_times.sum / random_times.size
puts "   #{random_times.size} random lookups in #{random_total.total_milliseconds.round(2)} ms"
puts "   Average per lookup: #{avg_random.round(3)} ms"
puts "   Throughput: #{(random_times.size / random_total.total_seconds).round} lookups/second"
puts ""

puts "=" * 50
puts "Benchmark complete!"
