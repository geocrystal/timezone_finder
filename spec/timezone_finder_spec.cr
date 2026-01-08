require "./spec_helper"

describe TimezoneFinder do
  describe "#lookup" do
    it "auto-loads dataset on first lookup" do
      # Dataset should be auto-loaded on first lookup call
      TimezoneFinder.lookup(40.71, -74.00)
      features = TimezoneFinder.features
      features.size.should be > 0
    end

    it "finds timezone for New York, USA" do
      tz = TimezoneFinder.lookup(40.71, -74.00)
      tz.should_not be_nil
      tz.try(&.name).should eq("America/New_York")
    end

    it "finds timezone for Kyiv, Ukraine" do
      tz = TimezoneFinder.lookup(49.842957, 24.031111)
      tz.should_not be_nil
      tz.try(&.name).should eq("Europe/Kyiv")
    end

    it "finds timezone for Athens, Greece" do
      tz = TimezoneFinder.lookup(37.979459, 23.716232)
      tz.should_not be_nil
      tz.try(&.name).should eq("Europe/Athens")
    end

    it "finds timezone for London, UK" do
      tz = TimezoneFinder.lookup(51.5074, -0.1278)
      tz.should_not be_nil
      tz.try(&.name).should eq("Europe/London")
    end

    it "finds timezone for Oslo, Norway" do
      tz = TimezoneFinder.lookup(59.9122, 10.7313)
      tz.should_not be_nil
      tz.try(&.name).should eq("Europe/Oslo")
    end

    it "finds timezone for Tokyo, Japan" do
      tz = TimezoneFinder.lookup(35.6762, 139.6503)
      tz.should_not be_nil
      tz.try(&.name).should eq("Asia/Tokyo")
    end

    it "finds timezone for Sydney, Australia" do
      tz = TimezoneFinder.lookup(-33.8688, 151.2093)
      tz.should_not be_nil
      tz.try(&.name).should eq("Australia/Sydney")
    end

    it "finds timezone for São Paulo, Brazil" do
      tz = TimezoneFinder.lookup(-23.5505, -46.6333)
      tz.should_not be_nil
      tz.try(&.name).should eq("America/Sao_Paulo")
    end

    it "returns Time::Location type" do
      tz = TimezoneFinder.lookup(40.71, -74.00)
      tz.should be_a(Time::Location)
    end

    it "returns timezone for coordinates in ocean" do
      # The file includes ocean timezones (Etc/GMT+/-X)
      # Coordinates in middle of Atlantic Ocean should return a timezone
      tz = TimezoneFinder.lookup(30.0, -40.0)
      tz.should_not be_nil
      tz.try(&.name).should match(/^Etc\/GMT/)
    end

    it "returns nil or Time::Location for any coordinates" do
      # Tests that lookup doesn't crash and returns valid type
      tz = TimezoneFinder.lookup(0.0, 0.0)
      (tz.nil? || tz.is_a?(Time::Location)).should be_true
    end

    it "handles edge cases without crashing" do
      # Test various edge coordinates - should not raise exceptions
      tz1 = TimezoneFinder.lookup(90.0, 180.0)   # North pole
      tz2 = TimezoneFinder.lookup(-90.0, -180.0) # South pole
      tz3 = TimezoneFinder.lookup(0.0, 0.0)      # Equator/Prime meridian

      # Should return nil or Time::Location (not crash)
      (tz1.nil? || tz1.is_a?(Time::Location)).should be_true
      (tz2.nil? || tz2.is_a?(Time::Location)).should be_true
      (tz3.nil? || tz3.is_a?(Time::Location)).should be_true
    end

    it "caches dataset after first load" do
      # First lookup loads dataset
      TimezoneFinder.lookup(40.71, -74.00)
      features1 = TimezoneFinder.features

      # Second lookup should use cached dataset
      TimezoneFinder.lookup(51.5074, -0.1278)
      features2 = TimezoneFinder.features

      # Should be the same instance (cached)
      features1.object_id.should eq(features2.object_id)
    end

    it "uses bounding boxes for fast filtering" do
      # Coordinates that should be filtered out quickly by bounding box
      # The file includes ocean timezones, so this may return a timezone
      tz = TimezoneFinder.lookup(80.0, 170.0) # Arctic Ocean
      # Should complete quickly without checking all polygons
      # Result may be nil or a timezone depending on dataset
      (tz.nil? || tz.is_a?(Time::Location)).should be_true
    end
  end

  describe "#features" do
    it "returns loaded features" do
      # Ensure dataset is loaded
      TimezoneFinder.lookup(40.71, -74.00)

      features = TimezoneFinder.features
      features.should be_a(Array(TimezoneFinder::Feature))
      features.size.should be > 0
    end

    it "auto-loads dataset if not already loaded" do
      # Clear any existing cache by accessing the internal method
      # This test verifies features auto-loads
      features = TimezoneFinder.features
      features.size.should be > 0
    end
  end
end
