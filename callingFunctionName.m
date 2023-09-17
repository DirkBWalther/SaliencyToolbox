% callingFunctionName returns the name of the calling function's calling function.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function name = callingFunctionName()

st = dbstack;

if (length(st) < 3)
  name = '';
else
  [~,name] = fileparts(st(3).name);
end
