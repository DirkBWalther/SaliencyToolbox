% displayMap - displays a map in the current axes.
%
% displayMap(map)
%    Display map in the current axes object.
%
% displayMap(map,normalizeFlag)
%    If normalizeFlag is 1, the map is maximum-normalized,
%    if it is 2, then the map is max-normalized and scaled
%    to the dimensions of map.origImage (default: 0 - no normalization).
%
% See also displayMaps, displayPyramid, dataStructures, showImage.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function displayMap(map,varargin)

if isempty(varargin)
  normalizeFlag = 0;
else
  normalizeFlag = varargin{1};
end

if isstruct(map)
  img = map.data;
  if (normalizeFlag == 2)
    img = imresize(img,map.origImage.size(1:2),'bilinear');
  end
else
  img = map;
end

if (normalizeFlag >= 1)
  img = 255*mat2gray(img);
end

image(img);
colormap(gray(255));
axis image;

if isstruct(map)
  title(map.label);
end
