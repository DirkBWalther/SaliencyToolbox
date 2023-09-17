% makeLTUsegmentNetwork - creates an LTU network for map segmentation.
%
% LTUnetwork = makeLTUSsegmentNetwork(mapSize,thresh)
%    Creates a network of linear threshold units for segmenting
%    a map of size mapSize with threshold thresh.
%    See section 3 of this paper for details:
%      Walther, D., and Koch, C. (2006). Modeling attention to salient 
%      proto-objects. Neural Networks 19, pp. 1395-1407.
%
% See also LTUsegmentMap, LTUsimulate, dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function LTUnetwork = makeLTUsegmentNetwork(mapSize,thresh)

numPix = prod(mapSize);
h = mapSize(1);
w = mapSize(2);

units = 5;
numCells = numPix * units;

% set up the connection matrix as a sparse matrix
con = sparse(numCells,numCells);

% now wire up all the connections
% cell 1 is the input from the select signal
% cell 2 is the input from the image
% cell 3 is an inhibitory interneuron fed from cell 2
% cell 4 pools the lateral input from the neighbors (P cell)
% cell 5 computes the output from all this (S cell)

% set up the network connections
hunits = h * units;
for x = 1:w
  for y = 1:h
    base = (x-1)*hunits + (y-1)*units + 1;
    
    % cell 1 to cell 5
    con(base,base+4) = 1;
    
    % cell 2 to cell 3 to cell 5
    con(base+1,base+2) = -1;
    con(base+2,base+4) = -2;
    
    % inputs from neighboring pixels to cell 4
    if (x > 1) con(base-hunits+4,base+3) = 1; end
    if (x < w) con(base+hunits+4,base+3) = 1; end
    if (y > 1) con(base- units+4,base+3) = 1; end
    if (y < h) con(base+ units+4,base+3) = 1; end
    
    % finally, connect cell 4 to cell 5
    con(base+3,base+4) = 1;
  end
end

LTUnetwork.connections = con;
LTUnetwork.thresholds = repmat([0 0 -thresh 1 1],1,numPix);
idx = ([1:numPix] - 1) * units + 1;
LTUnetwork.input_idx = [idx+1,idx];
LTUnetwork.output_idx = idx+4;
LTUnetwork.numCells = numCells;
LTUnetwork.label = sprintf('segmentation network for %d x %d maps',w,h);
