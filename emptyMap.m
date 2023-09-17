% emptyMap - creates an empty map.
%
% map = emptyMap(mapSize,label)
%    Creates a map with a data field of zeros(mapSize) with the given
%    label.
%
% map = emptyMap(mapSize)
%    Leaves the label field empty.
%
% map = emptyMap
%    Leaves the data field empty.
%
% See also dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function map = emptyMap(mapSize,label)

map.origImage = [];
if (nargin >= 2)
  map.label = label;
else
  map.label = '';
end
if (nargin >= 1)
  map.data = zeros(mapSize);
else
  map.data = [];
end
map.date = clock;
map.parameters = [];
