# Release v1.1.0 - Bug Fixes and Improvements

**Release Date**: March 11, 2026
**Status**: Stable ✅

---

## 🎉 Overview

This release fixes all critical bugs that prevented the code from running. The simulation now works correctly out of the box!

## 🐛 What's Fixed

### Critical Bug Fixes

1. **Missing Initialization Calls** (run.m)
   - Added `calcuVisibleSat()` - Initialize visible satellites
   - Added `getTriCoord()` - Calculate triangle coordinates
   - Created `scheduler` object before use

2. **Missing Utility Functions** - Added 8 new functions:
   
   **+tools package** (5 functions):
   - `LatLngCoordi2Length.m` - Geographic distance calculation
   - `getEarthLength.m` - Satellite beam ground projection
   - `find3dBAgle.m` - 3dB beamwidth calculation
   - `getPointAngleOfUsr.m` - Satellite-to-user pointing angles
   - `findPointXY.m` - Coordinate transformation
   
   **+antenna package** (3 functions):
   - `getSatAntennaServG.m` - Satellite antenna gain
   - `getUsrAntennaServG.m` - User terminal antenna gain
   - `initialUsrAntenna.m` - Antenna configuration

3. **Code Quality Issues** - Fixed 7 files:
   - Removed duplicate code blocks
   - Removed orphaned brackets
   - Improved error handling

## ✨ What's New

- **quick_start.m** - Quick test script for new users
- **test_fix.m** - Comprehensive test suite with metrics
- **CHANGELOG.md** - Detailed version history
- **CONTRIBUTING.md** - Contribution guidelines
- Improved satellite data generation

## 📊 Performance

Test results (54 satellites, 800 users, 1 scheduling period):

```
SINR Metrics:
  Average:    9.82 dB
  Median:    10.00 dB
  p90:       11.38 dB
  Outage:     0.00%

Fairness & Satisfaction:
  Jain Index:       0.9898
  Satisfaction:    85.03%
```

## 📥 Installation

### Update Existing Installation

```bash
cd leo-bh-scheduling
git pull origin main
```

### New Installation

```bash
git clone https://github.com/yuanhaobupt/leo-bh-scheduling.git
cd leo-bh-scheduling
```

### Test Installation

```matlab
addpath(genpath('.'));
generate_test_satellite_data();
quick_start;
```

## ⚠️ Breaking Changes

**None** - Backward compatible with v1.0.0

## 📝 Full Changelog

See [CHANGELOG.md](CHANGELOG.md) for complete details.

## 🙏 Acknowledgments

Thanks to all users who reported issues and tested the fixes!

---

**Full Changelog**: https://github.com/yuanhaobupt/leo-bh-scheduling/compare/v1.0.0...v1.1.0
