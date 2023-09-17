% makeDyadicPyramid - creates a dyadic Gaussian pyramid.
%
% pyr = makeDyadicPyramid(map)
%    Creates a Gaussian pyramid by blurring and subsampling 
%    map by a factor of 2 repeatedly, as long as both width 
%    and height are larger than 1.
%
% pyr = makeDyadicPyramid(map,depth)
%    Creates at most depth levels.
%
% See also mexGaussianSubsample, makeGaussianPyramid, makeSqrt2Pyramid, 
%          dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function pyr = makeDyadicPyramid(map,varargin)

if (isempty(varargin)) depth = -1;
else depth = varargin{1}; end

lab = map.label;

pyr.origImage = map.origImage;
pyr.label = lab;
pyr.type = 'dyadic';
map.label = [lab '-1'];
map.parameters.type = 'dyadic';

pyr.levels(1) = map;

n = 1;
while (min(size(pyr.levels(n).data)) > 1)
  if ((depth > 0) & (n >= depth)) break; end
  n = n + 1;
  newMap = [];
  newMap.origImage = map.origImage;
  newMap.label = sprintf('%s-%d',lab,n);
  newMap.data = gaussianSubsample(pyr.levels(n-1).data);
  newMap.date = clock;
  newMap.parameters.type = 'dyadic';
  pyr.levels(n) = newMap;
end

pyr.date = clock;
