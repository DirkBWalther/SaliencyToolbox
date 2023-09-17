% defaultLevelParams - returns a default levelParams structure.
%
% levelParams = defaultLevelParams
%    Returns a default structure with saliency parameters.
%
% levelParams = defaultLevelParams(pyramidType)
%    Initializes parameters for a particular pyramidType:
%       'dyadic' - pyramids with downsampling by a factor of 2 (default)
%       'sqrt2'  - pyramids with downsampling by a factor of sqrt(2)
%    This makes a difference for the levels for the computation of the
%    center-surround differences.
%
% See also guiLevelParams, centerSurround, winnerToImgCoords, 
%          defaultSaliencyParams, dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function levelParams = defaultLevelParams(pyramidType)

if (nargin < 1)
  pyramidType = 'dyadic';
end

% These are the default levels for pyramidType='dyadic'.
% Note for comparison with the iNVT C++ code: 
% Since Matlab starts counting at 1 and C++ at 0,
% you need to subtract 1 from the *Level values to obtain
% the equivalent values for the iNVT code.
% The *Delta values stay the same, of course.
levelParams.minLevel = 3;
levelParams.maxLevel = 5;
levelParams.minDelta = 3;
levelParams.maxDelta = 4;
levelParams.mapLevel = 5;
 

% these are the modified values for 'sqrt2'
if strcmp(pyramidType,'sqrt2')
  levelParams.minLevel = levelParams.minLevel*2 - 1;
  levelParams.maxLevel = levelParams.maxLevel*2 - 1;
  levelParams.mapLevel = levelParams.mapLevel*2 - 1;
  levelParams.minDelta = levelParams.minDelta*2;
  levelParams.maxDelta = levelParams.maxDelta*2;
end

