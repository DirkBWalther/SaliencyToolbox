% makeGaborFilter - returns a 3d stack of 2d Gabor filters for each phase.
%
% filter = makeGaborFilter(gaborParams, angle, makeDisk)
%    Returns a two-dimensional Gabor filter with the parameter:
%    gaborParams - a struct with the following fields:
%       filterPeriod - the period of the filter in pixels,
%       elongation - the ratio of length versus width,
%       filterSize - the size of the filter in pixels,
%       stddev - the standard deviation of the Gaussian envelope in pixels.
%       phases - the phase angles to be used.
%    angle - the angle of orientation, in degrees,
%    makeDisk - if 1, enforce a disk-shaped filter, i.e. set all values
%               outside of a circle with diameter gaborParams.filterSize to 0.
%
% filter = makeGaborFilter(gaborParams, angle)
%    Returns a two-dimensional Gabor filter, assuming makeDisk = 0.
%
% See also gaborFilterMap, defaultSaliencyParams.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function filter = makeGaborFilter(gaborParams, angle, varargin)

if isempty(varargin)
  makeDisk = 0;
else
  makeDisk = varargin{1};
end

% repare parameters
major_stddev = gaborParams.stddev;
minor_stddev = major_stddev * gaborParams.elongation;
max_stddev = max(major_stddev,minor_stddev);

sz = gaborParams.filterSize;
if (sz == -1)
  sz = ceil(max_stddev*sqrt(10));
else
  sz = floor(sz/2); 
end

rtDeg = pi / 180 * angle;

omega = 2 * pi / gaborParams.filterPeriod;
co = cos(rtDeg);
si = -sin(rtDeg);
major_sigq = 2 * major_stddev^2;
minor_sigq = 2 * minor_stddev^2;

% prepare grids for major and minor components
vec = [-sz:sz];
vlen = length(vec);
vco = vec*co;
vsi = vec*si;

major = repmat(vco',1,vlen) + repmat(vsi,vlen,1);
major2 = major.^2;
minor = repmat(vsi',1,vlen) - repmat(vco,vlen,1);
minor2 = minor.^2;

phase0 = exp(- major2 / major_sigq - minor2 / minor_sigq);

% create the actual filters
for p = 1:length(gaborParams.phases)
  psi = pi / 180 * gaborParams.phases(p);
  result = cos(omega * major + psi) .* phase0;

  % enforce disk shape?
  if (makeDisk)
    result((major2+minor2) > (gaborParams.filterSize/2)^2) = 0;
  end

  % normalization
  result = result - mean(result(:));
  filter(:,:,p) = result / sqrt(sum(result(:).^2));
end
