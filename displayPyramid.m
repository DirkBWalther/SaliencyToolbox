% displayPyramid - displays a pyramid in a new figure.
%
% displayPyramid(pyr)
%    Displays all levels of pyr in a new figure.
%
% displayPyramid(pyr,normalizeFlag)
%    If normalizeFlag is 1, the maps are maximum-normalized,
%    if it is 2, then the maps are max-normalized and scaled
%    to the dimensions of map.origImage (default: 0).
%
% See also displayMap, displayMaps, dataStructures, showImage.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function displayPyramid(pyr,varargin)

margin = 0.001;

if isempty(varargin)
  normalizeFlag = 0;
else
  normalizeFlag = varargin{1};
end

figure('NumberTitle','off','Name',pyr.label);

for l = 1:length(pyr.levels)
  if (l == 1)
    axes('position',[0,0+margin,2/3-margin,1-margin]);
  else
    f = 0.5^(l-1);
    axes('position',[2/3,f+margin,f*2/3-margin,f-margin]);
  end
  displayMap(pyr.levels(l),normalizeFlag);
  axis off;
end

  
