% getRGB(img) - extracts the r, g, and b parts for a color image.
%
% [r,g,b,in] = getRGB(img,lumThresh)
%   Returns the r, g, and b components of img as well as
%   the intensity used for normalization in color
%   opponency computations, i.e. max(r,g,b).
%   r, g, and b values at locations below lowThresh
%   are set to zero.
%
% [r,g,b,in] = getRGB(img)
%   Use lumThresh = 0.1 as default.
%
% See also makeRedGreenPyramid, makeBlueYellowPyramid.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function [r,g,b,in] = getRGB(img,varargin)

if isempty(varargin)
  lumThresh = 0.1;
else
  lumThresh = varargin{1};
end

r = img(:,:,1);
g = img(:,:,2);
b = img(:,:,3);
in = max(max(r,g),b);

% set everything below the luminance threshold to zero
lowIn = (in < lumThresh);
r(lowIn) = 0;
g(lowIn) = 0;
b(lowIn) = 0;
