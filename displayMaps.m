% displayMaps - displays a set of maps in the current figure.
%
% displayMaps(maps)
%    Displays all maps in the array of maps (cell or normal array) 
%    in the current figure.
%
% displayMaps(maps,normalizeFlag)
%    If normalizeFlag is 1, the maps are maximum-normalized,
%    if it is 2, then the maps are max-normalized and scaled
%    to the dimensions of map.origImage (default: 1).
%
% See also displayMap, displayPyramid, dataStructures, showImage

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function displayMaps(maps,varargin)

if (isempty(varargin)) normalizeFlag = 1;
else normalizeFlag = varargin{1}; end

numMaps = numel(maps);
subDims(1) = ceil(sqrt(numMaps));
subDims(2) = ceil(numMaps / subDims(1));

if iscell(maps)
  sz = size(maps{1}.data);
  if (sz(1) < sz(2))
    w = min(subDims);
    h = max(subDims);
  else
    w = max(subDims);
    h = min(subDims);
  end

  if (numMaps == 1)
    set(gcf,'Name',maps{1}.label);
  end

  for m = 1:numMaps
    subplot(h,w,m);
    displayMap(maps{m},normalizeFlag);
  end
else
  sz = size(maps(1).data);
  if (sz(1) < sz(2))
    w = min(subDims);
    h = max(subDims);
  else
    w = max(subDims);
    h = min(subDims);
  end
  
  if (numMaps == 1)
    set(gcf,'Name',maps(1).label);
  end

  for m = 1:numMaps
    subplot(h,w,m);
    displayMap(maps(m),normalizeFlag);
  end
end
