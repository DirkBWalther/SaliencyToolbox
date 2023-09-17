% displayImage - displays an image in a convenient way in the current axes.
%
% displayImage(img) - displays image in the current axis (wrapper for imshow)
%    img can be of any numerical type or a logical, and it
%        must have two (gray-scale) or three (RGB) dimensions.
%    img can be an Image structure (see initializeImage).
%    The image is scaled appropriately.
%
% displayImage(img,doNormalize)
%    If doNormalize is 1, the image is maximum-normalized 
%    (default: 0).
%
% See also displayMap, displayMaps, showImage, initializeImage, dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function displayImage(img,doNormalize)

if (nargin < 2)
  doNormalize = 0;
end

if (isa(img,'struct'))
  displayImage(loadImage(img),doNormalize);
  return;
end

if doNormalize
  imshow(img,[]);
else
  imshow(img);
end
axis image;
