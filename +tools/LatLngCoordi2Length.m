function distance = LatLngCoordi2Length(coord1, coord2, R)
% LATLNGCOORDI2LENGTH Calculate the distance between two points on Earth's surface
% 
% Inputs:
%   coord1 - [longitude, latitude] of first point (degrees)
%   coord2 - [longitude, latitude] of second point (degrees)
%   R      - Earth radius (meters)
%
% Output:
%   distance - Distance between the two points (meters)
%
% Uses the Haversine formula for great-circle distance

% Convert degrees to radians
lon1 = coord1(1) * pi / 180;
lat1 = coord1(2) * pi / 180;
lon2 = coord2(1) * pi / 180;
lat2 = coord2(2) * pi / 180;

% Haversine formula
dlon = lon2 - lon1;
dlat = lat2 - lat1;

a = sin(dlat/2)^2 + cos(lat1) * cos(lat2) * sin(dlon/2)^2;
c = 2 * asin(sqrt(a));

distance = R * c;

end
