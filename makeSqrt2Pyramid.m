% makeSqrt2Pyramid - creates a sqrt(2) Gaussian pyramid.
%
% pyr = makeSqrt2Pyramid(map)
%    Creates a Gaussian pyramid with levels separated by a 
%    factor of sqrt(2) by bilinear interpolation between 
%    levels of a dyadic Gaussian pyramid.
%
% pyr = makeSqrt2Pyramid(map,depth)
%    Creates at most depth levels.
%
% See also makeDyadicPyramid, mexGaussianSubsample, makeGaussianPyramid, dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function pyr = makeSqrt2Pyramid(map,varargin)

if (isempty(varargin)) depth = -1;
else depth = varargin{1}; end

lab = map.label;

pyr.origImage = map.origImage;
pyr.label = lab;
pyr.type = 'sqrt2';
map.label = [lab '-1'];
map.parameters.type = 'sqrt2';

pyr.levels(1) = map;

method = 'bilinear';

n = 1;
while (min(size(pyr.levels(n).data)) > 1)
  if ((depth > 0) & (n >= depth)) break; end
  
  n = n + 1;
  
  newMap = [];
  newMap.origImage = map.origImage;
  newMap.label = sprintf('%s-%d',lab,n);
  
  if (mod(n,2) == 0)
    
    % even levels: interpolate from previous level
    prev = pyr.levels(n-1).data;
    if (min(size(prev)) <= 4)
      method = 'nearest';
    end
    newMap.data = imresize(prev,round(size(prev)/sqrt(2)),method);
  else
    
    % odd levels: dyadic subsampling from the level two back
    newMap.data = gaussianSubsample(pyr.levels(n-2).data);
  end
  
  newMap.date = clock;
  newMap.parameters.type = 'sqrt2';
  pyr.levels(n) = newMap;
end

pyr.date = clock;
