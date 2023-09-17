function resultImg = contrastModulate(img, modulationMap, varargin)
% contrastModulate - contrast modulates an image according to a map
%
% resultImg = contrastModulate(img, modulationMap, baseContrast, baseColor)
%    contrast modulates image img such that that it has full
%    contrast where modulationMask is 1. 
%    Img is an Image structure, modulationMap a map assumed 
%    to be scaled between 0 and 1 and of the same size as img. 
%    baseContrast (between 0 and 1) is the image contrast 
%    where modulationMap = 0. 
%    baseColor is the color at locations with low contrast.
%
% resultImg = contrastModulate(img, modulationMap, baseContrast)
%    assumes baseColor = [1 1 1] (white).
%
% resultImg = contrastModulate(img, modulationMap, baseContrast)
%    assumes baseContrast = 0 (opaque).
%
% See also plotSalientLocation, dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

if length(varargin) >= 1
  baseCon = varargin{1};
else
  baseCon = 0;
end

if length(varargin) >= 2
  baseCol = varargin{2};
  if numel(baseCol) == 1
    baseCol = baseCol * [1 1 1];
  end
else
  baseCol = [1 1 1];
end

imData = loadImage(img);
if img.dims == 2
  imData = repmat(imData,[1 1 3]);
end

m = modulationMap.data;
if (size(m,1) ~= img.size(1) || size(m,2) ~= img.size(2))
  error('Image and modulation map must have the same size!');
end

alpha = m * (1 - baseCon) + baseCon;
beta = 1 - alpha;
for c = 1:3
  res(:,:,c) = alpha.*imData(:,:,c) + beta*baseCol(c);
end

if isnan(img.filename)
  label = 'contrast modulated image';
else
  label = ['contrast modulated ' img.filename];
end
resultImg = initializeImage(res,label);
