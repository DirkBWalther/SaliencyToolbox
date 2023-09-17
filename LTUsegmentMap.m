% LTUsegmentMap - segment map using a network of linear threshold units.
%
% [resultMap,segMaps] = LTUsegmentMap(map,seedPoint)
%    Segment the map around the seedPoint using a network of linear
%    threshold units. Returns a binary map in resultMap and the 
%    intermediate maps at each time step in segMaps.
%    This function is A LOT slower than fastSegmentMap! 
%    (But it works with model neurons.)
%    See section 3 of this paper for details:
%      Walther, D., and Koch, C. (2006). Modeling attention to salient 
%      proto-objects. Neural Networks 19, pp. 1395-1407.
%
% [resultMap,segMaps] = LTUsegmentMap(map,seedPoint,thresh)
%    Use threshold thresh for segmentation (default: 0.1).
%    This threshold is relative to the map activity at
%    the seedPoint, i.e. the actual threshold is thresh * map(seedPoint).
%
% See also makeLTUsegmentNetwork, LTUsimulate, fastSegmentMap, estimateShape, dataStructures.
  
% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function [resultMap,segMaps] = LTUsegmentMap(map,seedPoint,varargin)

if isempty(varargin) thresh = 0.1;
else thresh = varargin{1}; end

numIter = -1;
eps = 0.001;

% prepare data structures for the result
imSize = size(map.data);
lab = map.label;
seedVal = map.data(seedPoint(1),seedPoint(2));
if (seedVal < eps)
  resultMap.origImage = map.origImage;
  resultMap.label = ['seg-0: ' lab];
  resultMap.data = zeros(imSize);
  resultMap.date = clock;
  resultMap.parameters = map.parameters;
  segMaps = [];
  return;
end

% create the segmentation network
LTUnetwork = makeLTUsegmentNetwork(imSize,thresh);
select = zeros(imSize);
select(seedPoint(1),seedPoint(2)) = 1;
input = [map.data(:)/seedVal;select(:)];
states = zeros(1,LTUnetwork.numCells);

keepgoing = 1;
iter = 0;
while (keepgoing)
  iter = iter + 1;
  [output,states] = LTUsimulate(LTUnetwork,states,input,2);
  segMaps(iter).origImage = map.origImage;
  segMaps(iter).label = sprintf('seg-%d: %s',iter,lab);
  segMaps(iter).data = reshape(output,imSize);
  segMaps(iter).date = timeString;
  segMaps(iter).parameters = map.parameters;
  if (numIter > 0)
    keepgoing = (iter <= numIter);
  else
    if (iter == 1)
      keepgoing = 1;
    else
      keepgoing = ~isequal(output,old_output);
    end
    old_output = output;
  end
end

resultMap = segMaps(end);
