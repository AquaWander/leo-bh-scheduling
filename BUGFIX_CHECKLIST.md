# 代码修复清单 - 2026年3月11日

本文档记录了所有需要修复的代码错误，分为3类：
1. **必须修复** - 导致程序崩溃的错误
2. **建议修复** - 提高代码质量的改进
3. **新增文件** - 缺失的工具函数

---

## 🔴 必须修复 (Critical Fixes)

### 1. `+simSatSysClass/@simController/run.m`

**问题**: 缺少关键初始化调用，导致 `VisibleSat`, `CoordiTri`, `scheduler` 未定义

**修复**: 在第15行后添加

```matlab
% 在 self.DiscrInvesArea(); 之后添加 (约第15行)
self.getTriCoord();
```

在第27行后添加 (约第27行):
```matlab
% 在 getDiscrInNonWrap() 之后添加
%% Calculate visible satellites
self.calcuVisibleSat();
if self.ifDebug == 1
    fprintf('Visible satellite calculation completed\n');
end
```

在第344行修改 (创建scheduler对象):
```matlab
% 修改前:
scheduler.getinterface(interface);

% 修改后:
scheduler = simSatSysClass.schedulerObj();
scheduler.getinterface(interface);
```

---

### 2. `+simSatSysClass/@simController/calcuVisibleSat.m`

**问题**: 第216-267行有重复代码块和孤立括号

**修复**: 删除第217-267行的所有重复代码

```matlab
% 第216行之后应该直接是:
end

self.VisibleSat = tempVisibleSat;
```

---

### 3. `+simSatSysClass/@simController/getNeighborSat.m`

**问题**: 第213行有孤立括号 `)`

**修复**: 删除第213行

---

### 4. `+simSatSysClass/@simInterface/simInterface.m`

**问题**: 第116-143行有重复的属性定义块

**修复**: 删除第116-143行的重复代码块

```matlab
% 第115行 end 之后应该直接是:
%% 
 methods
```

---

### 5. `+simSatSysClass/@schedulerObj/getCurUsers.m`

**问题**: 第29-38行和第109-119行有重复代码块

**修复**: 
- 删除第29-38行的重复循环
- 删除第109-119行的重复elseif块

---

### 6. `+simSatSysClass/@schedulerObj/generateBHST.m`

**问题**: 第88行有孤立括号 `)`

**修复**: 删除第88行

---

### 7. `+methods/UsrsTraffic_Method.m`

**问题**: 第72行有孤立括号 `)`

**修复**: 删除第72行

---

## 🟡 建议修复 (Recommended Improvements)

### 8. `utils/generate_test_satellite_data.m`

**问题**: 生成的卫星轨道不覆盖研究区域

**修复**: 使用已修复的版本，确保卫星经过目标区域 [102-108°E, 26-30°N]

---

## 🟢 新增文件 (New Files Required)

需要在项目根目录创建以下包和函数：

### **+tools 包** (创建 `+tools` 文件夹)

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

### **+antenna 包** (创建 `+antenna` 文件夹)

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

## 📝 提交到GitHub的步骤

### 1. 创建新分支
```bash
git checkout -b bugfix/code-errors
```

### 2. 应用修复
按照上述清单逐个修复文件

### 3. 测试验证
```matlab
% 运行测试
cd('leo-bh-scheduling');
addpath(genpath('.'));
generate_test_satellite_data();
setConfig;
controller = simSatSysClass.simController(Config, 1, 1, 0);
DataObj = controller.run();
KPIs = calcuUserKPIs(DataObj);
```

### 4. 提交更改
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

### 5. 推送并创建PR
```bash
git push origin bugfix/code-errors
```

然后在GitHub上创建Pull Request

---

## 🔍 修复验证清单

- [ ] 所有语法错误已修复
- [ ] 测试脚本 `test_fix.m` 运行成功
- [ ] 生成的卫星数据覆盖研究区域
- [ ] 所有新增文件已添加到git
- [ ] README更新（如有必要）
- [ ] CHANGELOG更新（如有必要）

---

## 💡 长期改进建议

1. **添加单元测试**: 为工具函数添加测试用例
2. **CI/CD**: 设置GitHub Actions自动测试
3. **代码规范**: 使用MLint检查代码质量
4. **文档**: 为所有函数添加完整的帮助文档
5. **示例数据**: 提供真实的STK轨道数据样本

---

生成日期: 2026年3月11日
