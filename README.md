# timezone_finder

Offline timezone lookup by latitude and longitude for Crystal. This library automatically loads timezone boundary data and provides fast, accurate timezone lookups using spherical geometry.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     timezone_finder:
       github: geocrystal/timezone_finder
   ```

2. Run `shards install`

## Usage

The library automatically loads timezone files from the `data/downloads` directory on the first lookup call:

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

### Changing the Data Directory

To use a different directory for timezone files:

```crystal
TimezoneFinder::Dataset.default_directory = "path/to/your/timezone/files"
# The dataset will be reloaded from the new directory on next lookup
```

## Performance

Benchmark results (run with `crystal run --release benchmark.cr`):

- **Dataset loading**: ~8 seconds to load 406 timezone features (one-time cost)
- **Single lookup performance**:
  - Average: ~63ms per lookup
  - Range: 9ms (fastest) to 143ms (slowest)
- **Batch lookups**: ~70ms per lookup, ~14 lookups/second
- **Random coordinate lookups**: ~149ms per lookup, ~7 lookups/second

The dataset is automatically loaded and cached on the first lookup call, so subsequent lookups are fast. Lookups are faster when the target timezone is found earlier in the dataset.

## Development

Run the tests:

```sh
crystal spec
```

Run the benchmark:

```sh
crystal run --release benchmark.cr
```

## Contributing

1. Fork it (<https://github.com/your-github-user/timezone_finder/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Anton Maminov](https://github.com/your-github-user) - creator and maintainer
