% clamp - clamps data at the top and/or bottom.
%
% data = clamp(data,bottom,top)
%    Sets all values of data that are less than bottom to bottom,
%    and all values greater than top to top.
%
% data = clamp(data,bottom)
%    Sets all values less than bottom to bottom.
%    
% data = clamp(data,[],top)
%    Sets all values greater than top to top.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function data = clamp(data,bottom,top)

if ~isempty(bottom)
  data(data < bottom) = bottom;
end

if nargin >= 3
  data(data > top) = top;
end
