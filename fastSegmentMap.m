% fastSegmentMap - segment map around a seedPoint.
%
% resultMap = fastSegmentMap(map,seedPoint)
%    Segment the map around the seedPoint, returns a binary
%    resultMap. This function is A LOT faster than LTUsegmentMap!
%
% resultMap = fastSegmentMap(map,seedPoint,thresh)
%    Use threshold thresh for segmentation (default: 0.1).
%    This threshold is relative to the map activity at
%    the seedPoint.
%
% This function corresponds to eqs. 13 and 14 in:
%      Walther, D., and Koch, C. (2006). Modeling attention to salient 
%      proto-objects. Neural Networks 19, pp. 1395-1407.
%
% See also LTUsegmentMap, estimateShape, dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function resultMap = fastSegmentMap(map,seedPoint,varargin)

if isempty(varargin) thresh = 0.05;
else thresh = varargin{1}; end

eps = 0.001;

resultMap.origImage = map.origImage;
resultMap.label = ['seg: ' map.label];
resultMap.parameters = map.parameters;

seedVal = map.data(seedPoint(1),seedPoint(2));
if (seedVal < eps)
  debugMsg(sprintf('seedVal = %g',seedVal));
  resultMap.origImage = map.origImage;
  resultMap.label = ['seg-0: ' map.label];
  resultMap.data = zeros(size(map.data));
  resultMap.date = clock;
  resultMap.parameters = map.parameters;
  segMaps = [];
  return;
end
  
bw = im2bw(map.data/seedVal,thresh);
labels = bwlabel(bw,4);
sVal = labels(seedPoint(1),seedPoint(2));
if (sVal > 0)
  resultMap.data = double(labels == sVal);
else
  resultMap.data = zeros(size(map.data));
end

resultMap.date = clock;
