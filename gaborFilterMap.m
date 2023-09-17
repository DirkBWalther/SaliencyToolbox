% gaborFilterMap - compute a gabor-filtered version of a map.
%
% result = gaborFilterMap(map,gaborParams,angle)
%    Convolves the map data with a gabor filter with
%    gaborParams at orientation angle.
%
%    gaborParams is a struct with the following fields:
%       filterPeriod - the period of the filter in pixels
%       elongation - the ratio of length versus width
%       filterSize - the size of the filter in pixels
%       stddev - the standard deviation of the Gaussian in pixels
%
% See also makeGaborFilter, makeOrientationPyramid, defaultSaliencyParams.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function resultMap = gaborFilterMap(map,gaborParams,angle)

% create the filters
gf = makeGaborFilter(gaborParams, angle);

% convolve the map with the filters
for p = 1:length(gaborParams.phases)
  fres(:,:,p) = conv2PreserveEnergy(map.data,gf(:,:,p));  
end

resultMap.origImage = map.origImage;
resultMap.label = sprintf('Gabor%3.1f',angle);
resultMap.data = sum(abs(fres),3);
resultMap.date = clock;
resultMap.parameters.gaborParams = gaborParams;
