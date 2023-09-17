% combineMaps - returns the sum of a vector of maps.
%
% resultMap = combineMaps(maps,label)
%   Adds the data fields in the maps vactor and returns
%   the result as a map with label as the label.
%
% See also dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function result = combineMaps(maps,label)

result = maps(1);
result.label = label;

lm = length(maps);
result.data = zeros(size(maps(1).data));
for m = 1:lm
  result.data = result.data + maps(m).data;
end

result.date = clock;
