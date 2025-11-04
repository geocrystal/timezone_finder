# Data Files

This directory contains the timezone boundary data files used by the `timezone_finder` library.

## File

- **`combined-with-oceans.json`** (~150MB)
  - A GeoJSON FeatureCollection containing timezone boundaries
  - Includes timezone boundaries including oceanic timezones
  - Source: [timezone-boundary-builder](https://github.com/evansiroky/timezone-boundary-builder) releases

## Automatic Download

The data file is automatically downloaded during `shards install` via the postinstall script. The script:

1. Checks if the file already exists (skips download if present)
2. Downloads the `timezones-with-oceans.geojson.zip` file from the release
3. Extracts `combined-with-oceans.json` to this directory

## Manual Download

If you need to manually download or update the data file, you can run:

```sh
crystal run scripts/postinstall.cr
```

## File Format

The `combined-with-oceans.json` file is a GeoJSON FeatureCollection where:
- Each feature has a `properties.tzid` field containing the timezone ID (e.g., "Europe/Kyiv")
- Each feature has a `geometry` field containing either a Polygon or MultiPolygon
- Coordinates are in `[longitude, latitude]` format (GeoJSON standard)

## Git Ignore

This directory is typically ignored by git (via `.gitignore`) since the data file is large (~150MB) and is automatically downloaded during installation.
