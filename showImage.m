% showImage - displays an image in a convenient way.
%
% showImage(img) - displays image in a new window
%    img can be of any numerical type or a logical, and it
%        must have two (gray-scale) or three (RGB) dimensions.
%    img can be an Image structure (see initializeImage).
%    The image is scaled appropriately.
%
% showImage(img,title)
%    Rename the figure window to title.
%
% showImage(img,...,doNormalize)
%    If doNormalize is 1, the image is maximum-normalized 
%    (default: 0).
%
% h = showImage(...)
%    returns the handle of the figure.
%
% See also displayImage, displayMap, displayMaps, initializeImage, dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function h = showImage(img,varargin)

title = [];
doNormalize = 0;
for i = 1:length(varargin)
  if (isstr(varargin{i}))
    title = varargin{i};
  else
    doNormalize = varargin{i};
  end
end

if (isa(img,'struct'))
  if (~any(isnan(img.filename)) & (length(title) == 0))
    title = img.filename;
  end
  hh = showImage(loadImage(img),title,doNormalize);
else
  if isempty(title)
    hh = figure;
  else
    hh = figure('Name',title,'NumberTitle','off');
  end
  displayImage(img,doNormalize);
end

if (nargout > 0)
  h = hh;
end
