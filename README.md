# timezone_finder

[![Crystal CI](https://github.com/geocrystal/timezone_finder/actions/workflows/crystal.yml/badge.svg)](https://github.com/geocrystal/timezone_finder/actions/workflows/crystal.yml)
[![GitHub release](https://img.shields.io/github/release/geocrystal/timezone_finder.svg)](https://github.com/geocrystal/timezone_finder/releases)
[![License](https://img.shields.io/github/license/geocrystal/timezone_finder.svg)](https://github.com/geocrystal/geojson/blob/main/LICENSE)

Offline timezone lookup by latitude and longitude for Crystal. This library automatically loads timezone boundary data and provides fast, accurate timezone lookups using spherical geometry.

## Data Source

The timezone boundary data used by this library comes from [timezone-boundary-builder](https://github.com/evansiroky/timezone-boundary-builder), a project that extracts timezone boundaries from OpenStreetMap data. The library uses the `combined-with-oceans.json` file, which contains timezone boundaries including oceanic timezones.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     timezone_finder:
       github: geocrystal/timezone_finder
   ```

2. Run `shards install`

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

- **Dataset loading**: ~3.2 seconds to load 443 timezone features (one-time cost)
- **Single lookup performance**:
  - Average: ~1.2ms per lookup
  - Range: 0.055ms (fastest) to 3.3ms (slowest)
- **Batch lookups**: ~1.1ms per lookup, ~915 lookups/second
- **Random coordinate lookups**: ~0.4ms per lookup, ~2600 lookups/second

The dataset is automatically loaded and cached on the first lookup call, so subsequent lookups are fast.

*Note: Benchmark results were tested on Intel(R) Core(TM) i7-8550U (8) @ 4.00 GHz*

## Development

1. Clone this repository:

   ```sh
   git clone https://github.com/geocrystal/timezone_finder.git
   cd timezone_finder
   ```

2. Download the timezone data file (required for lookups):

   ```sh
   crystal run scripts/postinstall.cr
   ```

   This will automatically download the `combined-with-oceans-1970.json` file (~150MB) from the [timezone-boundary-builder releases](https://github.com/evansiroky/timezone-boundary-builder/releases). The file is stored in the `data/` directory and will be cached for subsequent runs.

3. Run the tests:

   ```sh
   crystal spec
   ```

4. Run the benchmark:

   ```sh
   crystal run --release benchmark/benchmark.cr
   ```

## Contributing

1. Fork it (<https://github.com/geocrystal/timezone_finder/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Anton Maminov](https://github.com/mamantoha) - creator and maintainer
