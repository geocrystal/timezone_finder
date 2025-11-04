# timezone_finder

Offline timezone lookup by latitude and longitude for Crystal. This library automatically loads timezone boundary data and provides fast, accurate timezone lookups using spherical geometry.

## Data Source

The timezone boundary data used by this library comes from [timezone-boundary-builder](https://github.com/evansiroky/timezone-boundary-builder), a project that extracts timezone boundaries from OpenStreetMap data. The library uses the `combined-with-oceans-1970.json` file, which contains timezone boundaries that have been consistent since 1970, including oceanic timezones.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     timezone_finder:
       github: geocrystal/timezone_finder
   ```

2. Run `shards install`

3. Download the timezone data file (required for lookups):

   ```sh
   shards run download_data
   ```

   This will automatically download the `combined-with-oceans-1970.json` file (~150MB) from the [timezone-boundary-builder releases](https://github.com/evansiroky/timezone-boundary-builder/releases). The file is stored in the `data/` directory and will be cached for subsequent runs.

## Usage

The library automatically loads the timezone data file from the `data` directory on the first lookup call:

```crystal
require "timezone_finder"

# Lookup timezone for Kyiv, Ukraine
tz = TimezoneFinder.lookup(49.842957, 24.031111)
puts tz.try(&.name) # => "Europe/Kyiv"

# Lookup timezone for New York, USA
tz = TimezoneFinder.lookup(40.71, -74.00)
puts tz.try(&.name) # => "America/New_York"

# Returns Time::Location? which can be used directly with Time
if tz = TimezoneFinder.lookup(51.5074, -0.1278)
  time = Time.now(tz)
  puts time # => Current time in London timezone
end
```

## Performance

Benchmark results (run with `crystal run --release benchmark/benchmark.cr`):

- **Dataset loading**: ~2.7 seconds to load 329 timezone features (one-time cost)
- **Single lookup performance**:
  - Average: ~1.5ms per lookup
  - Range: 0.069ms (fastest) to 4.5ms (slowest)
- **Batch lookups**: ~1.8ms per lookup, ~570 lookups/second
- **Random coordinate lookups**: ~0.6ms per lookup, ~1700 lookups/second

The dataset is automatically loaded and cached on the first lookup call, so subsequent lookups are fast.

## Development

Run the tests:

```sh
crystal spec
```

Run the benchmark:

```sh
crystal run --release benchmark/benchmark.cr
```

## Contributing

1. Fork it (<https://github.com/your-github-user/timezone_finder/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Anton Maminov](https://github.com/your-github-user) - creator and maintainer
