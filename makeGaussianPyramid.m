% makeGaussianPyramid - creates a Gaussian pyramid from map.
%
% pyr = makeGaussianPyramid(map,type)
%    Creates a Gaussian pyramid by blurring and subsampling 
%    map repeatedly, as long as both width and height are 
%    larger than 1.
%       type: 'dyadic' or 'sqrt2'
%
% pyr = makeGaussianPyramid(map,type,depth)
%    Creates at most depth levels.
%
% See also makeDyadicPyramid, makeSqrt2Pyramid, dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function pyr = makeGaussianPyramid(map,type,varargin)

if (isempty(varargin)) depth = -1;
else depth = varargin{1}; end

switch type
  case 'dyadic'
    pyr = makeDyadicPyramid(map,depth);
  case 'sqrt2'
    pyr = makeSqrt2Pyramid(map,depth);
  otherwise
    error(['Unknown pyramidType: ' type]);
end
