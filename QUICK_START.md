# Quick Start Guide

## 🚀 Get Started in 3 Steps

### Step 1: Clone Repository
```bash
git clone https://github.com/yuanhaobupt/leo-bh-scheduling.git
cd leo-bh-scheduling
```

### Step 2: Setup MATLAB
```matlab
% Add paths
addpath(genpath('.'));

% Generate test satellite data
generate_test_satellite_data();

% Run quick test
quick_start;
```

### Step 3: View Results
```
Average SINR:       9.82 dB  ✅
Outage Rate:        0.00%    ✅
Fairness Index:     0.9898   ✅
Satisfaction Rate:  85.03%   ✅
```

---

## ✅ What's Fixed in v1.1.0

### Critical Bugs Fixed
1. **Missing initialization calls** - Code now runs without crashes
2. **Missing utility functions** - Added 8 new functions in +tools and +antenna packages
3. **Code quality issues** - Removed duplicate code and orphaned brackets

### New Features
- **quick_start.m** - One-click test script
- **test_fix.m** - Comprehensive test suite
- **CHANGELOG.md** - Detailed version history
- **CONTRIBUTING.md** - Contribution guidelines

---

## 📖 Documentation

- **README.md** - Full project documentation
- **CHANGELOG.md** - Version history and changes
- **BUGFIX_CHECKLIST_EN.md** - Detailed fix checklist
- **FIXES_COMPLETED.md** - Test results and completion report

---

## ⚠️ Important Note

**If you cloned before March 11, 2026**, please update:
```bash
git pull origin main
generate_test_satellite_data()
quick_start
```

---

## 📊 Performance Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Average SINR | 9.82 dB | ✅ Good |
| Median SINR | 10.00 dB | ✅ Good |
| Outage Rate | 0.00% | ✅ Excellent |
| Avg Delay | 48.59 ms | ✅ Good |
| Fairness | 0.9898 | ✅ Excellent |
| Satisfaction | 85.03% | ✅ Good |

---

## 🎯 Next Steps

1. **Modify configuration** - Edit `setConfig.m` to change parameters
2. **Run full experiments** - Execute `run_TabuSearch.m`
3. **Visualize results** - Use scripts in `visualize/` folder
4. **Read documentation** - See `README.md` for details

---

## 🆘 Need Help?

- **Issues**: https://github.com/yuanhaobupt/leo-bh-scheduling/issues
- **Email**: yuan_hao@bupt.edu.cn
- **Docs**: See documentation files in repository

---

**Your LEO satellite beam hopping scheduling code is ready to use!** 🛰️
