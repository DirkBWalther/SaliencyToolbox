% centerSurround - computes center-surround difference maps.
%
% [featureMaps,csLevels] = centerSurround(pyramid,salParams)
%    computes the center-surround maps in the pyramid
%    according to the parameters in salParams.
%
%    featureMaps is a vector of maps with the results.
%    csLevels returns the center and surround levels in
%       pyramid for later reference.
%
% See also defaultSaliencyParams, defaultLevelParams, makeSaliencyMap, 
%          centerSurroundTopDown, dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function [featureMaps,csLevels] = centerSurround(pyr,params)

debugMsg('',pyr);

% determine a few parameters
lp = params.levelParams;
siz = size(pyr.levels(lp.mapLevel).data);
numLevels = length(pyr.levels);

% have an exclusion map?
exclusionIdx = [];
if isfield(params,'exclusionMask')
  if ~isempty(params.exclusionMask)
    switch class(params.exclusionMask)
      case 'struct'
        exclusionIdx = (imresize(params.exclusionMask.data,siz,'nearest') ~= 0);
      case {'double','uint8'}
        exclusionIdx = (imresize(params.exclusionMask,siz,'nearest') ~= 0);
      case 'logical'
        exclusionIdx = imresize(params.exclusionMask,siz,'nearest');
      otherwise
        error(['Unknown class type for params.exclusionMask: ' class(params.exclusionMask)]);
    end
  end
end

% resize everything that needs to be resized
c = 1;
for l = lp.minLevel:(lp.maxLevel + lp.maxDelta)
  if (l > numLevels) break; end
  maps(c).origImage = pyr.levels(l).origImage;
  maps(c).label = pyr.levels(l).label;
  maps(c).data = imresize(pyr.levels(l).data,siz,'nearest');
  maps(c).data(exclusionIdx) = 0;
  maps(c).date = clock;
  idx(l) = c;
  c = c + 1;
end

% compute all the c-s differences
cc = 1;
borderSize = round(max(siz)/20);
lab = pyr.label;
for l = lp.minLevel:lp.maxLevel;
  for d = lp.minDelta:lp.maxDelta
    l2 = l + d;
    if (l2 > numLevels) continue; end
    featureMaps(cc).origImage = maps(idx(l)).origImage;
    featureMaps(cc).label = sprintf('%s (%d-%d)',lab,l2,l);
    featureMaps(cc).data = attenuateBorders(abs(maps(idx(l)).data - maps(idx(l2)).data),...
                                            borderSize);
    csLevels(cc).centerLevel = l;
    csLevels(cc).surroundLevel = l2;
    featureMaps(cc).date = clock;
    featureMaps(cc).parameters = params;
    cc = cc + 1;
  end
end
