% makeHuePyramid - creates a hue distance pyramid.
%
% huePyr = makeHuePyramid(image,type,hueParams)
%    Creates a Gaussian Pyramid from a hue distance map.
%       image: Image structure of a color image.
%       type: 'dyadic' or 'sqrt2'.
%       hueParams: contains the parameters for the target hue.
%
% huePyr = makeHuePyramid(image,type,hueParams,label)
%    Assign a label to the pyramid (default: 'Hue').
%
% See also hueDistance, skinHueParams, makeFeaturePyramids, 
%          dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function huePyr = makeHuePyramid(image,type,hueParams,varargin)

declareGlobal;

im = loadImage(image);

map.origImage = image;

if isempty(varargin)
  map.label = 'Hue';
else
  map.label = varargin{1};
end

map.data = hueDistance(im,hueParams);
map.date = clock;
map.parameters.hueParams = hueParams;

huePyr = makeGaussianPyramid(map,type);
