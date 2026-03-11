# Code Fix Checklist - March 11, 2026

This document records all code errors that need to be fixed, categorized into 3 types:
1. **Critical Fixes** - Errors causing program crashes
2. **Recommended Fixes** - Code quality improvements
3. **New Files** - Missing utility functions

---

## 🔴 Critical Fixes

### 1. `+simSatSysClass/@simController/run.m`

**Problem**: Missing critical initialization calls causing `VisibleSat`, `CoordiTri`, `scheduler` undefined

**Fix**: Add after line 15

```matlab
% After self.DiscrInvesArea(); add:
self.getTriCoord();
```

Add after line 27 (approximately):
```matlab
% After getDiscrInNonWrap() add:
%% Calculate visible satellites
self.calcuVisibleSat();
if self.ifDebug == 1
    fprintf('Visible satellite calculation completed\n');
end
```

Modify line 344 (create scheduler object):
```matlab
% Before:
scheduler.getinterface(interface);

% After:
scheduler = simSatSysClass.schedulerObj();
scheduler.getinterface(interface);
```

---

### 2. `+simSatSysClass/@simController/calcuVisibleSat.m`

**Problem**: Duplicate code block at lines 216-267

**Fix**: Delete all duplicate code at lines 217-267

```matlab
% Line 216 should be followed directly by:
end

self.VisibleSat = tempVisibleSat;
```

---

### 3. `+simSatSysClass/@simController/getNeighborSat.m`

**Problem**: Orphaned bracket `)` at line 213

**Fix**: Delete line 213

---

### 4. `+simSatSysClass/@simInterface/simInterface.m`

**Problem**: Duplicate property definition block at lines 116-143

**Fix**: Delete duplicate code block at lines 116-143

```matlab
% Line 115 'end' should be followed directly by:
%% 
 methods
```

---

### 5. `+simSatSysClass/@schedulerObj/getCurUsers.m`

**Problem**: Duplicate code blocks at lines 29-38 and 109-119

**Fix**: 
- Delete duplicate loop at lines 29-38
- Delete duplicate elseif block at lines 109-119

---

### 6. `+simSatSysClass/@schedulerObj/generateBHST.m`

**Problem**: Orphaned bracket `)` at line 88

**Fix**: Delete line 88

---

### 7. `+methods/UsrsTraffic_Method.m`

**Problem**: Orphaned bracket `)` at line 72

**Fix**: Delete line 72

---

## 🟡 Recommended Improvements

### 8. `utils/generate_test_satellite_data.m`

**Problem**: Generated satellite orbits don't cover the research area

**Fix**: Use the improved version that ensures satellites pass over target area [102-108°E, 26-30°N]

---

## 🟢 New Files Required

Create the following packages and functions in the project root directory:

### **+tools Package** (create `+tools` folder)

#### `+tools/LatLngCoordi2Length.m`
```matlab
function distance = LatLngCoordi2Length(coord1, coord2, R)
% LATLNGCOORDI2LENGTH Calculate distance between two points on Earth
% Inputs:
%   coord1 - [lon, lat] in degrees
%   coord2 - [lon, lat] in degrees  
%   R - Earth radius in meters
% Output:
%   distance - Distance in meters

lon1 = coord1(1) * pi / 180;
lat1 = coord1(2) * pi / 180;
lon2 = coord2(1) * pi / 180;
lat2 = coord2(2) * pi / 180;

dlon = lon2 - lon1;
dlat = lat2 - lat1;

a = sin(dlat/2)^2 + cos(lat1) * cos(lat2) * sin(dlon/2)^2;
c = 2 * asin(sqrt(a));

distance = R * c;
end
```

#### `+tools/getEarthLength.m`
```matlab
function length_on_earth = getEarthLength(angle_rad, height)
% GETEARTHLENGTH Calculate ground length for satellite beam angle
% Inputs:
%   angle_rad - Beam angle in radians
%   height - Satellite altitude in meters
% Output:
%   length_on_earth - Length on Earth surface in meters

length_on_earth = 2 * height * tan(angle_rad / 2);
end
```

#### `+tools/find3dBAgle.m`
```matlab
function angle_3dB = find3dBAgle(freq)
% FIND3DBAGLE Calculate 3dB beamwidth angle
% Input: freq - Frequency in Hz
% Output: angle_3dB - 3dB beamwidth in radians

freq_GHz = freq / 1e9;

if freq_GHz >= 20
    angle_deg = 2.5;  % Ka-band
elseif freq_GHz >= 12
    angle_deg = 3.5;  % Ku-band
elseif freq_GHz >= 2
    angle_deg = 6;    % S-band
else
    angle_deg = 5;
end

angle_3dB = angle_deg * pi / 180;
end
```

#### `+tools/getPointAngleOfUsr.m`
```matlab
function [theta, phi] = getPointAngleOfUsr(satPos, satNextPos, usrPos, height)
% GETPOINTANGLEOFSR Calculate pointing angles from satellite to user
% Inputs:
%   satPos - Satellite [lon, lat] in degrees
%   satNextPos - Next satellite position (not used in simplified model)
%   usrPos - User [lon, lat] in degrees
%   height - Satellite altitude in meters
% Outputs:
%   theta - Elevation angle in radians
%   phi - Azimuth angle in radians

R_earth = 6371.393e3;

sat_lon = satPos(1) * pi / 180;
sat_lat = satPos(2) * pi / 180;
usr_lon = usrPos(1) * pi / 180;
usr_lat = usrPos(2) * pi / 180;

dlon = usr_lon - sat_lon;
dlat = usr_lat - sat_lat;

a = sin(dlat/2)^2 + cos(sat_lat) * cos(usr_lat) * sin(dlon/2)^2;
angular_dist = 2 * asin(sqrt(a));
ground_dist = R_earth * angular_dist;

if ground_dist > 0
    theta = atan(height / ground_dist);
else
    theta = pi / 2;
end

y = sin(dlon) * cos(usr_lat);
x = cos(sat_lat) * sin(usr_lat) - sin(sat_lat) * cos(usr_lat) * cos(dlon);
phi = atan2(y, x);
end
```

#### `+tools/findPointXY.m`
```matlab
function [x, y, z] = findPointXY(interface, lat, lon)
% FINDPOINTXY Convert lat/lon to ECEF Cartesian coordinates
% Inputs:
%   interface - Interface object (not used in simplified version)
%   lat - Latitude in degrees
%   lon - Longitude in degrees
% Outputs:
%   x, y, z - Cartesian coordinates in meters

R_earth = 6371.393e3;

lat_rad = lat * pi / 180;
lon_rad = lon * pi / 180;

x = R_earth * cos(lat_rad) * cos(lon_rad);
y = R_earth * cos(lat_rad) * sin(lon_rad);
z = R_earth * sin(lat_rad);
end
```

---

### **+antenna Package** (create `+antenna` folder)

#### `+antenna/getSatAntennaServG.m`
```matlab
function G = getSatAntennaServG(angleOfInv, angleOfPoi, freq)
% GETSATANTENNASERVG Calculate satellite antenna gain
% Inputs:
%   angleOfInv - Incident angle [theta, phi] in radians
%   angleOfPoi - Pointing angle [alpha, beta] in radians
%   freq - Frequency in Hz
% Output:
%   G - Antenna gain (linear scale)

c = 3e8;
lambda = c / freq;
D = 0.5;  % Antenna diameter (m)
eta = 0.65;  % Efficiency

G_max = eta * (pi * D / lambda)^2;
theta_3dB = 1.22 * lambda / D;

delta_theta = angleOfInv(1) - angleOfPoi(1);
delta_phi = angleOfInv(2) - angleOfPoi(2);
off_axis = sqrt(delta_theta^2 + delta_phi^2);

if off_axis < 3 * theta_3dB
    G = G_max * exp(-2.77 * (off_axis / theta_3dB)^2);
else
    G = G_max * 0.01;
end
end
```

#### `+antenna/getUsrAntennaServG.m`
```matlab
function G = getUsrAntennaServG(angle, freq, type)
% GETUSRANTENNASERVG Calculate user terminal antenna gain
% Inputs:
%   angle - Elevation angle in radians
%   freq - Frequency in Hz
%   type - Antenna type (1=omnidirectional, 2=directional)
% Output:
%   G - Antenna gain (linear scale)

if nargin < 3
    type = 1;
end

G = 1.0;  % 0 dBi default

if type == 2
    G = 3.16;  % ~5 dBi
    if angle > 0
        elevation_factor = sin(angle);
        G = G * (0.5 + 0.5 * elevation_factor);
    else
        G = 0.1;
    end
end
end
```

#### `+antenna/initialUsrAntenna.m`
```matlab
function UsrAntennaConfig = initialUsrAntenna()
% INITIALUSRAINTENNA Initialize user antenna configuration
% Output:
%   UsrAntennaConfig - Structure with antenna parameters

UsrAntennaConfig = struct();
UsrAntennaConfig.type = 1;
UsrAntennaConfig.gain = 1.0;
UsrAntennaConfig.efficiency = 0.65;
UsrAntennaConfig.noiseTemp = 150;
UsrAntennaConfig.noiseFigure = 7;
UsrAntennaConfig.txPower_dBm = 23;
UsrAntennaConfig.height = 1.5;
UsrAntennaConfig.polarization = 2;
UsrAntennaConfig.ifDeGravity = 0;
end
```

---

## 📝 Steps to Commit to GitHub

### 1. Create New Branch
```bash
git checkout -b bugfix/code-errors
```

### 2. Apply Fixes
Fix each file according to the checklist above

### 3. Test
```matlab
% Run test
cd('leo-bh-scheduling');
addpath(genpath('.'));
generate_test_satellite_data();
setConfig;
controller = simSatSysClass.simController(Config, 1, 1, 0);
DataObj = controller.run();
KPIs = calcuUserKPIs(DataObj);
```

### 4. Commit
```bash
git add .
git commit -m "Fix critical bugs and add missing utility functions

- Fix missing initialization calls in run.m
- Remove duplicate code blocks in multiple files
- Remove orphaned brackets causing syntax errors
- Add missing +tools package with 5 utility functions
- Add missing +antenna package with 3 antenna functions
- Improve satellite data generation for test coverage

Fixes #[issue_number] (if applicable)"
```

### 5. Push and Create PR
```bash
git push origin bugfix/code-errors
```

Then create Pull Request on GitHub

---

## 🔍 Fix Verification Checklist

- [ ] All syntax errors fixed
- [ ] Test script `test_fix.m` runs successfully
- [ ] Generated satellite data covers research area
- [ ] All new files added to git
- [ ] README updated (if necessary)
- [ ] CHANGELOG updated (if necessary)

---

## 💡 Long-term Improvement Suggestions

1. **Add unit tests**: Add test cases for utility functions
2. **CI/CD**: Setup GitHub Actions for automatic testing
3. **Code standards**: Use MLint to check code quality
4. **Documentation**: Add complete help documentation for all functions
5. **Example data**: Provide real STK orbit data samples

---

Generated: March 11, 2026
