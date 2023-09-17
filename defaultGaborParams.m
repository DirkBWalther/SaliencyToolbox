% defaultGaborParams - returns a default gaborParams structure.
%
% gaborParams = defaultGaborParams
%    Returns a default structure with saliency parameters.
%
% gaborParams - a structure with parameters for Gabor orientation filters.
%       filterPeriod: the period of the filter in pixels.
%         elongation: the ratio of length versus width.
%         filterSize: the size of the filter in pixels.
%             stddev: the standard deviation of the Gaussian envelope in pixels.
%             phases: the phase angles to be used.
%
% See also makeGaborFilter, gaborFilterMap, makeOrientationPyramid, 
%          defaultSaliencyParams, dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function gaborParams = defaultGaborParams

gaborParams.filterPeriod = 7;
gaborParams.elongation = 1;
gaborParams.filterSize = 9;
gaborParams.stddev = 2.3333;
gaborParams.phases = [0 90];
