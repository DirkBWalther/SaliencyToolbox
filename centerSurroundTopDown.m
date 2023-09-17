% centerSurroundTopDown - pseudo center-surround for top-down maps.
%
% [featureMaps,csLevels] = centerSurroundTopDown(pyramid,salParams)
%    Only resizes and border-attenuates the level maps of the pyramid.
%    This version does NOT compute center-surround differences.
%    It is meant for top-down attention maps fed in from an outside
%    source, e.g. object-sensitive maps. This version was used in:
%      Dirk B. Walther & Christof Koch (2007). Attention in 
%      Hierarchical Models of Object Recognition. In P. Cisek, 
%      T. Drew & J. F. Kalaska (Eds.), Progress in Brain Research: 
%      Computational Neuroscience: Theoretical insights into brain 
%      function. Amsterdam: Elsevier.
%
%    featureMaps is a vector of maps with the results.
%    csLevels returns the center and surround levels in
%       pyramid for later reference.
%
% See also centerSurround, defaultSaliencyParams, makeSaliencyMap,
%          dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function [featureMaps,csLevels] = centerSurroundTopDown(pyr,salParams)

switch salParams.pyramidType
  case 'sqrt2'
    base = sqrt(0.5);
  case 'dyadic'
    base = 0.5;
  otherwise
    error(['Unknown pyramidType: ' salParams.pyramidType]);
end

siz = floor(pyr.origImage.size(1:2) * base^(salParams.levelParams.mapLevel-1));
borderSize = round(max(siz)/20);

for i = 1:length(pyr.levels)
  featureMaps(i) = pyr.levels(i);
  tmp = imresize(pyr.levels(i).data,siz,'nearest');
  featureMaps(i).data = attenuateBorders(tmp,borderSize);
  featureMaps(i).date = clock;
  featureMaps(i).parameters = salParams;
  csLevels(i).centerLevel = i;
  csLevels(i).surroundLevel = i;
end
