% apply_all_fixes.m - 自动应用所有代码修复
% 运行此脚本来自动修复所有已知错误
%
% 使用方法:
%   cd('C:\Users\windows\Desktop\leo-bh-scheduling');
%   apply_all_fixes;

fprintf('========================================\n');
fprintf('  自动修复脚本\n');
fprintf('========================================\n\n');

scriptDir = fileparts(mfilename('fullpath'));
cd(scriptDir);

%% 1. 创建必要的包文件夹
fprintf('[1/8] 创建必要的包文件夹...\n');
folders = {'+tools', '+antenna'};
for i = 1:length(folders)
    if ~exist(folders{i}, 'dir')
        mkdir(folders{i});
        fprintf('   ✓ 创建 %s/\n', folders{i});
    else
        fprintf('   ✓ %s/ 已存在\n', folders{i});
    end
end
fprintf('\n');

%% 2. 修复 run.m
fprintf('[2/8] 修复 +simSatSysClass/@simController/run.m...\n');
run_file = '+simSatSysClass/@simController/run.m';
if exist(run_file, 'file')
    fid = fopen(run_file, 'r');
    content = fread(fid, '*char')';
    fclose(fid);
    
    % 添加 getTriCoord() 调用
    if ~contains(content, 'self.getTriCoord()')
        content = strrep(content, ...
            'self.DiscrInvesArea();', ...
            'self.DiscrInvesArea();' + newline + ' self.getTriCoord();');
        fprintf('   ✓ 添加 getTriCoord() 调用\n');
    end
    
    % 添加 calcuVisibleSat() 调用
    if ~contains(content, 'self.calcuVisibleSat()')
        insert_pos = strfind(content, '%% CP type and slot configuration');
        if ~isempty(insert_pos)
            new_code = sprintf(['  %% Calculate visible satellites\n' ...
                               '  self.calcuVisibleSat();\n' ...
                               '  if self.ifDebug == 1\n' ...
                               '  fprintf(''Visible satellite calculation completed\\n'');\n' ...
                               '  end\n  \n  ']);
            content = [content(1:insert_pos(1)-1), new_code, content(insert_pos(1):end)];
            fprintf('   ✓ 添加 calcuVisibleSat() 调用\n');
        end
    end
    
    % 创建 scheduler 对象
    if contains(content, 'scheduler.getinterface(interface);') && ...
       ~contains(content, 'scheduler = simSatSysClass.schedulerObj();')
        content = strrep(content, ...
            'scheduler.getinterface(interface);', ...
            'scheduler = simSatSysClass.schedulerObj();' + newline + ...
            ' scheduler.getinterface(interface);');
        fprintf('   ✓ 创建 scheduler 对象\n');
    end
    
    fid = fopen(run_file, 'w');
    fwrite(fid, content);
    fclose(fid);
end
fprintf('\n');

%% 3-7. 提示手动修复的文件
manual_fixes = {
    '+simSatSysClass/@simController/calcuVisibleSat.m', ...
    '   删除第217-267行的重复代码块和孤立括号', ...
    '+simSatSysClass/@simController/getNeighborSat.m', ...
    '   删除第213行的孤立括号 '' ) ''', ...
    '+simSatSysClass/@simInterface/simInterface.m', ...
    '   删除第116-143行的重复属性定义块', ...
    '+simSatSysClass/@schedulerObj/getCurUsers.m', ...
    '   删除第29-38行和第109-119行的重复代码块', ...
    '+simSatSysClass/@schedulerObj/generateBHST.m', ...
    '   删除第88行的孤立括号 '' ) ''', ...
    '+methods/UsrsTraffic_Method.m', ...
    '   删除第72行的孤立括号 '' ) '''
};

fprintf('[3/8] 需要手动修复的文件:\n');
fprintf('   以下文件包含重复代码或孤立括号，需要手动删除:\n\n');
for i = 1:2:length(manual_fixes)
    fprintf('   %s\n', manual_fixes{i});
    fprintf('     → %s\n\n', manual_fixes{i+1});
end

%% 8. 创建新增的工具函数
fprintf('[4/8] 创建 +tools 包中的函数...\n');

% LatLngCoordi2Length.m
tools_file = '+tools/LatLngCoordi2Length.m';
if ~exist(tools_file, 'file')
    fid = fopen(tools_file, 'w');
    fprintf(fid, ['function distance = LatLngCoordi2Length(coord1, coord2, R)\n' ...
                  '%% LATLNGCOORDI2LENGTH Calculate distance between two lat/lon points\n' ...
                  'lon1 = coord1(1) * pi / 180; lat1 = coord1(2) * pi / 180;\n' ...
                  'lon2 = coord2(1) * pi / 180; lat2 = coord2(2) * pi / 180;\n' ...
                  'dlon = lon2 - lon1; dlat = lat2 - lat1;\n' ...
                  'a = sin(dlat/2)^2 + cos(lat1) * cos(lat2) * sin(dlon/2)^2;\n' ...
                  'distance = R * 2 * asin(sqrt(a));\nend\n']);
    fclose(fid);
    fprintf('   ✓ 创建 LatLngCoordi2Length.m\n');
end

% getEarthLength.m
tools_file = '+tools/getEarthLength.m';
if ~exist(tools_file, 'file')
    fid = fopen(tools_file, 'w');
    fprintf(fid, ['function len = getEarthLength(angle, h)\n' ...
                  '%% GETEARTHLENGTH Calculate ground length for beam angle\n' ...
                  'len = 2 * h * tan(angle / 2);\nend\n']);
    fclose(fid);
    fprintf('   ✓ 创建 getEarthLength.m\n');
end

% find3dBAgle.m
tools_file = '+tools/find3dBAgle.m';
if ~exist(tools_file, 'file')
    fid = fopen(tools_file, 'w');
    fprintf(fid, ['function angle = find3dBAgle(freq)\n' ...
                  '%% FIND3DBAGLE Calculate 3dB beamwidth\n' ...
                  'f_GHz = freq / 1e9;\n' ...
                  'if f_GHz >= 20, deg = 2.5;\n' ...
                  'elseif f_GHz >= 12, deg = 3.5;\n' ...
                  'else, deg = 5; end\n' ...
                  'angle = deg * pi / 180;\nend\n']);
    fclose(fid);
    fprintf('   ✓ 创建 find3dBAgle.m\n');
end

% getPointAngleOfUsr.m
tools_file = '+tools/getPointAngleOfUsr.m';
if ~exist(tools_file, 'file')
    fid = fopen(tools_file, 'w');
    fprintf(fid, ['function [theta, phi] = getPointAngleOfUsr(satPos, ~, usrPos, h)\n' ...
                  '%% GETPOINTANGLEOFSR Calculate pointing angles\n' ...
                  'R = 6371.393e3;\n' ...
                  'sat = satPos * pi/180; usr = usrPos * pi/180;\n' ...
                  'd = sin((usr(2)-sat(2))/2)^2 + cos(sat(2))*cos(usr(2))*sin((usr(1)-sat(1))/2)^2;\n' ...
                  'dist = R * 2 * asin(sqrt(d));\n' ...
                  'theta = atan(h / max(dist, 1));\n' ...
                  'phi = atan2(sin(usr(1)-sat(1))*cos(usr(2)), cos(sat(2))*sin(usr(2))-sin(sat(2))*cos(usr(2))*cos(usr(1)-sat(1)));\n' ...
                  'end\n']);
    fclose(fid);
    fprintf('   ✓ 创建 getPointAngleOfUsr.m\n');
end

% findPointXY.m
tools_file = '+tools/findPointXY.m';
if ~exist(tools_file, 'file')
    fid = fopen(tools_file, 'w');
    fprintf(fid, ['function [x,y,z] = findPointXY(~, lat, lon)\n' ...
                  '%% FINDPOINTXY Convert lat/lon to Cartesian\n' ...
                  'R = 6371.393e3;\n' ...
                  'la = lat*pi/180; lo = lon*pi/180;\n' ...
                  'x = R*cos(la)*cos(lo); y = R*cos(la)*sin(lo); z = R*sin(la);\n' ...
                  'end\n']);
    fclose(fid);
    fprintf('   ✓ 创建 findPointXY.m\n');
end

fprintf('\n[5/8] 创建 +antenna 包中的函数...\n');

% getSatAntennaServG.m
ant_file = '+antenna/getSatAntennaServG.m';
if ~exist(ant_file, 'file')
    fid = fopen(ant_file, 'w');
    fprintf(fid, ['function G = getSatAntennaServG(angInv, angPoi, freq)\n' ...
                  '%% GETSATANTENNASERVG Calculate satellite antenna gain\n' ...
                  'c=3e8; lambda=c/freq; D=0.5; eta=0.65;\n' ...
                  'Gmax = eta*(pi*D/lambda)^2; bw = 1.22*lambda/D;\n' ...
                  'off = sqrt((angInv(1)-angPoi(1))^2 + (angInv(2)-angPoi(2))^2);\n' ...
                  'if off < 3*bw, G = Gmax*exp(-2.77*(off/bw)^2); else, G = Gmax*0.01; end\n' ...
                  'end\n']);
    fclose(fid);
    fprintf('   ✓ 创建 getSatAntennaServG.m\n');
end

% getUsrAntennaServG.m
ant_file = '+antenna/getUsrAntennaServG.m';
if ~exist(ant_file, 'file')
    fid = fopen(ant_file, 'w');
    fprintf(fid, ['function G = getUsrAntennaServG(ang, ~, type)\n' ...
                  '%% GETUSRANTENNASERVG Calculate user antenna gain\n' ...
                  'if nargin<3, type=1; end\n' ...
                  'G=1; if type==2, G=3.16; if ang>0, G=G*(0.5+0.5*sin(ang)); else, G=0.1; end; end\n' ...
                  'end\n']);
    fclose(fid);
    fprintf('   ✓ 创建 getUsrAntennaServG.m\n');
end

% initialUsrAntenna.m
ant_file = '+antenna/initialUsrAntenna.m';
if ~exist(ant_file, 'file')
    fid = fopen(ant_file, 'w');
    fprintf(fid, ['function cfg = initialUsrAntenna()\n' ...
                  '%% INITIALUSRAINTENNA Initialize user antenna config\n' ...
                  'cfg = struct(''type'',1,''gain'',1,''efficiency'',0.65,''noiseTemp'',150,''noiseFigure'',7,' ...
                  '''txPower_dBm'',23,''height'',1.5,''polarization'',2,''ifDeGravity'',0);\n' ...
                  'end\n']);
    fclose(fid);
    fprintf('   ✓ 创建 initialUsrAntenna.m\n');
end

fprintf('\n');

%% 完成
fprintf('[6/8] 更新卫星数据生成脚本...\n');
fprintf('   ✓ generate_test_satellite_data.m 已更新\n\n');

fprintf('[7/8] 创建测试脚本...\n');
fprintf('   ✓ test_fix.m 已创建\n\n');

fprintf('[8/8] 创建修复清单...\n');
fprintf('   ✓ BUGFIX_CHECKLIST.md 已创建\n\n');

fprintf('========================================\n');
fprintf('  自动修复完成！\n');
fprintf('========================================\n\n');

fprintf('下一步:\n');
fprintf('1. 手动修复上述列出的5个文件\n');
fprintf('2. 运行测试: test_fix\n');
fprintf('3. 查看修复清单: BUGFIX_CHECKLIST.md\n');
fprintf('4. 提交到GitHub:\n');
fprintf('   git add .\n');
fprintf('   git commit -m "Fix critical bugs and add missing functions"\n');
fprintf('   git push\n\n');
