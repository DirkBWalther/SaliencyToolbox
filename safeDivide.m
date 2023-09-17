% safeDivide - divides two arrays, checking for 0/0.
%
% result = safeDivide(arg1,arg2)
%    returns arg1./arg2, where 0/0 is assumed to be 0 instead of NaN.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function result = safeDivide(arg1,arg2)

ze = (arg2 == 0);
arg2(ze) = 1;
result = arg1./arg2;
result(ze) = 0;
