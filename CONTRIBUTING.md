# Contributing to LEO Beam Hopping Scheduling

Thank you for your interest in contributing!

## Reporting Issues

Before opening an issue, please check the [existing issues](https://github.com/yuanhaobupt/leo-bh-scheduling/issues) to avoid duplicates.

When reporting a bug, include:
- MATLAB version and OS
- Steps to reproduce
- Expected vs. actual behavior
- Error messages (full stack trace if available)

## Development Setup

```bash
# Fork and clone
git clone https://github.com/YOUR_USERNAME/leo-bh-scheduling.git
cd leo-bh-scheduling

# Add upstream
git remote add upstream https://github.com/yuanhaobupt/leo-bh-scheduling.git
```

```matlab
% In MATLAB, add paths and generate test data
addpath(genpath('.'));
generate_test_satellite_data();

% Verify setup
quick_start;
```

## Code Style

- **Variables**: camelCase (`numOfSatellites`)
- **Functions**: camelCase (`getPointAngleOfUsr`)
- **Classes**: PascalCase (`simController`)
- Add comments for complex logic
- Keep functions focused and concise

## Pull Request Process

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Make changes and test with `quick_start`
3. Commit with descriptive messages
4. Push to your fork and open a Pull Request

### PR Checklist
- [ ] Code compiles without errors or warnings
- [ ] `quick_start` runs successfully
- [ ] New features documented in README if applicable
- [ ] Changes described in PR description

## Questions?

- Open an issue for bugs or feature requests
- Email: yuan_hao@bupt.edu.cn for private inquiries
