% winnerToImgCoords - converts winner location from map to image coordinates.
%
% winImgCo = winnerToImgCoords(winner,salParams)
%    Converts the winner location from saliency map coordinates
%    to image coordinates, based on the pyramid type and
%    the map level specified in salParams.
%
% See also defaultLevelParams, evolveWTA.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function winImgCo = winnerToImgCoords(winner,params)

if (params.useRandom)
  winner = winner + rand(size(winner));
end

mLevel = params.levelParams.mapLevel - 1;
switch params.pyramidType
  case 'dyadic'
    winImgCo = round((winner - 1) * 2^mLevel + 1);
  case 'sqrt2'
    winImgCo = round((winner - 1) * 2^(mLevel/2) + 1);
  otherwise
    error(['Unknown pyramidType: ' params.pyramidType]);
end
  
