function [row, col, ifUp] = findPointXY(obj, lat, lon)
% FINDPOINTXY Find discretization grid indices for given lat/lon
%
% Inputs:
%   obj - Interface or controller object with SeqDiscrArea property
%   lat - Latitude (degrees)
%   lon - Longitude (degrees)
%
% Outputs:
%   row  - Row index in discretization grid (1-based)
%   col  - Column index in discretization grid (1-based)
%   ifUp - Triangle orientation (0=down, 1=up)
%
% Returns (0, 0, 0) if point is outside the grid

seqArea = obj.SeqDiscrArea;

% Get rowNum from obj
try
    rowNum = obj.rowNum;
catch
    rowNum = size(obj.DiscrArea, 1);
end

% Find nearest triangle center
% SeqDiscrArea: col1=longitude, col2=latitude
dlat = seqArea(:,2) - lat;
dlon = seqArea(:,1) - lon;
[~, idx] = min(dlat.^2 + dlon.^2);

% Convert linear index to (row, col) using same formula as ij2Seq
row = mod(idx - 1, rowNum) + 1;
col = floor((idx - 1) / rowNum) + 1;

% Triangle orientation: odd columns = up, even columns = down
ifUp = mod(col, 2);

end
