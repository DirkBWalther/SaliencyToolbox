% makeRedGreenPyramid - creates a red-green opponency pyramid
%
% [rgPyr,rPyr,gPyr] = makeRedGreenPyramid(image,type)
%    Creates a gaussian pyramid from a red-green opponency map (rgPyr)
%    of image and, if requested, also the separate red (rPyr)
%    and green (gPyr) pyramids.
%      Image - Image structure for the input image.
%      type - 'dyadic' or 'sqrt2'
%
% For a dicussion of the particular definitions of color opponency used here, 
% see appendix A.2 of Dirk's PhD thesis:
%    Walther, D. (2006). Interactions of visual attention and object recognition: 
%    Computational modeling, algorithms, and psychophysics. Ph.D. thesis.
%    California Institute of Technology. 
%    http://resolver.caltech.edu/CaltechETD:etd-03072006-135433.
%
% See also makeBlueYellowPyramid, getRGB, makeGaussianPyramid, makeFeaturePyramids, dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function [rgPyr,rPyr,gPyr] = makeRedGreenPyramid(image,type)

declareGlobal;

im = loadImage(image);
[r,g,b,in] = getRGB(im);

rg = safeDivide((r-g),in);

if (nargout >= 1)
  map.origImage = image;
  map.label = 'Red/Green';
  map.data = rg;
  map.date = clock;
  rgPyr = makeGaussianPyramid(map,type);
end

if (nargout >= 2)
  map.origImage = image;
  map.label = 'Red';
  rr = clamp(rg,0);
  map.data = rr;
  map.date = clock;
  rPyr = makeGaussianPyramid(map,type);
end

if (nargout >= 3)
  map.origImage = image;
  map.label = 'Green';
  gg = clamp(-rg,0);
  map.data = gg;
  map.date = clock;
  gPyr = makeGaussianPyramid(map,type);
end
