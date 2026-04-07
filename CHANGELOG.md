# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-03-11

### Fixed

#### Missing Initializations (run.m)
- Added `calcuVisibleSat()` call to initialize visible satellites before access
- Added `getTriCoord()` call to calculate triangle vertex coordinates
- Created `scheduler` object before calling its methods

#### Duplicate Code Blocks (5 files)
- Removed duplicate code in `+simSatSysClass/@simController/calcuVisibleSat.m`
- Removed duplicate loops in `+simSatSysClass/@schedulerObj/getCurUsers.m`
- Removed duplicate property definitions in `+simSatSysClass/@simInterface/simInterface.m`

#### Orphaned Brackets (4 files)
- Fixed orphan `)` in `getNeighborSat.m`, `generateBHST.m`, `UsrsTraffic_Method.m`

### Added

#### Utility Packages
- **+tools**: 5 utility functions (coordinate conversion, distance, beamwidth calculations)
- **+antenna**: 3 antenna functions (satellite/user antenna gain patterns)
- **utils/generate_test_satellite_data.m**: Synthetic satellite data generator

#### Experiment Scripts
- `run_TabuSearch.m`, `run_DQN.m`: Baseline algorithm tests
- `run_ablation_SA.m`: SA mechanism ablation experiment
- `run_ablation_Ltabu.m`: Tabu tenure ablation experiment
- `run_traffic_skew_experiment.m`: Traffic distribution experiment
- `run_all_experiments.m`: Comprehensive experiment runner
- `run_visualization.m`: Batch visualization script

#### Documentation
- `CONTRIBUTING.md`: Contribution guidelines
- `quick_start.m`: One-click verification script

### Changed
- Improved satellite data generation to ensure coverage of research area [102-108E, 26-30N]
- Unified all user-facing script output to English
- Cleaned up `.gitignore` with comprehensive MATLAB patterns

### Performance

Test results (single scheduling period, 800 users, 7 visible satellites):

| Metric | Value |
|--------|-------|
| Average SINR | 9.82 dB |
| Median SINR | 10.00 dB |
| Outage Rate (<0 dB) | 0.00% |
| Average Delay | 48.59 ms |
| Jain Fairness Index | 0.9898 |
| Avg Satisfaction Rate | 85.03% |

---

## [1.0.0] - Initial Release

### Added
- Tabu Search beam hopping scheduling algorithm
- Simulated Annealing hybrid mechanism
- Beam footprint generation and scheduling framework
- User traffic generation with multiple distribution modes
- Performance metric calculation (SINR, throughput, fairness, satisfaction)
- Visualization tools for result analysis

---

[Compare v1.0.0...v1.1.0](https://github.com/yuanhaobupt/leo-bh-scheduling/compare/v1.0.0...v1.1.0)
