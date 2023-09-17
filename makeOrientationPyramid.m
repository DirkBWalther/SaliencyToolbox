% makeOrientationPyramid - creates an orientation pyramid.
%
% oriPyr = makeOrientationPyramid(intPyr,gaborParams,angle)
%    Creates an orientation pyramid from a given intensity
%    pyramid with Gabor filters defined in gaborParams and
%    at the orientation given by angle (in degrees, 0 is horizontal).
%
% See also gaborFilterMap, makeFeaturePyramids, makeIntensityPyramid, 
%          dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function oriPyr = makeOrientationPyramid(intPyr,gaborParams,angle,levels)

allLevels = 1:length(intPyr.levels);
if nargin < 4
  levels = allLevels;
end

oriPyr.origImage = intPyr.origImage;
oriPyr.label = sprintf('Gabor%3.1f',angle);
oriPyr.type = intPyr.type;

for l = levels
  oriPyr.levels(l) = gaborFilterMap(intPyr.levels(l),gaborParams,angle);
  oriPyr.levels(l).label = sprintf('%s-%d',oriPyr.levels(l).label,l);
end

for l = setdiff(allLevels,levels)
  oriPyr.levels(l) = emptyMap;
  oriPyr.levels(l).label = 'not computed';
end

oriPyr.date = clock;
