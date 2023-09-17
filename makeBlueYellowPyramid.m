% makeBlueYellowPyramid - creates a blue-yellow opponency pyramid.
%
% [byPyr,bPyr,yPyr] = makeBlueYellowPyramid(Image,type)
%    Creates a gaussian pyramid from a blue-yellow opponency map (byPyr)
%    of image and, if requested, also the separate blue (bPyr)
%    and yellow (yPyr) pyramids.
%      Image - Image structure of the input image.
%      type - 'dyadic' or 'sqrt2'
%
% For a dicussion of the particular definitions of color opponency used here, 
% see appendix A.2 of Dirk's PhD thesis:
%    Walther, D. (2006). Interactions of visual attention and object recognition: 
%    Computational modeling, algorithms, and psychophysics. Ph.D. thesis.
%    California Institute of Technology. 
%    http://resolver.caltech.edu/CaltechETD:etd-03072006-135433.
%
% See also makeRedGreenPyramid, getRGB, makeGaussianPyramid, 
%          makeFeaturePyramids, dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function [byPyr,bPyr,yPyr] = makeBlueYellowPyramid(image,type)

declareGlobal;

im = loadImage(image);
[r,g,b,in] = getRGB(im);

by = safeDivide(b-min(r,g),in);

if (nargout >= 1)
  map.origImage = image;
  map.label = 'Blue/Yellow';
  map.data = by;
  map.date = clock;
  byPyr = makeGaussianPyramid(map,type);
end

if (nargout >= 2)
  map.origImage = image;
  map.label = 'Blue';
  bb = clamp(by,0);
  map.data = bb;
  map.date = clock;
  bPyr = makeGaussianPyramid(map,type);
end

if (nargout >= 3)
  map.origImage = image;
  map.label = 'Yellow';
  yy = clamp(-by,0);
  map.data = yy;
  map.date = clock;
  yPyr = makeGaussianPyramid(map,type);
end

