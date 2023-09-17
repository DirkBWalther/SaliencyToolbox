% defaultSaliencyParams - returns a default salParams structure.
%
% params = defaultSaliencyParams
%    Returns a default structure with saliency parameters.
%
% params = defaultSaliencyParams(pyramidType)
%    Initializes parameters for a particular pyramidType:
%       'dyadic' - pyramids with downsampling by a factor of 2 (default)
%       'sqrt2'  - pyramids with downsampling by a factor of sqrt(2)
%    This makes a difference for the levels for the computation of the
%    center-surround differences.
%
% params = defaultSaliencyParams(...,imgSize)
%    Initializes params.foaSize to 1/6*min(w,h) (default: -1).
%    This is only important for params.IORtype='disk'.
%
% See also runSaliency, makeSaliencyMap, estimateShape, applyIOR, 
%          removeColorFeatures, winnerToImgCoords, dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function params = defaultSaliencyParams(varargin)

% this is only important for IORtype='disk'.
params.foaSize = -1;

% one of: 'dyadic','sqrt2'
params.pyramidType = 'dyadic';

% scan the arguments
for i = 1:length(varargin)
  switch class(varargin{i})
    case 'double'
      params.foaSize = round(max(varargin{i}(1:2)) / 6);
    case 'char'
      params.pyramidType = varargin{i};
    otherwise
      error(['Unknown data type for this function: ' class(varargin{i})]);
  end
end

% a cell array with a combination of: 
% 'Color','Intensities','Orientations','Hue','Skin','TopDown'
params.features = {'Color','Intensities','Orientations'};

% the weights in the same order as params.features
params.weights = [1 1 1];

% one of: 'shape','disk','None'
params.IORtype = 'shape';

% one of: 'None','shapeSM','shapeCM','shapeFM','shapePyr'
%params.shapeMode = 'shapePyr';
params.shapeMode = 'shapeFM';

% the pyramid level parameters
params.levelParams = defaultLevelParams(params.pyramidType);

% one of: 'None','LocalMax','Iterative'
params.normtype = 'Iterative';

% number of iterations for Iterative normalization
params.numIter = 3;

% 1 for using random jitter in converting from saliency map 
%   coordinates to image coordinates,
% 0 for not using random jitter
params.useRandom = 1;

% one of: 'Fast','LTU'
params.segmentComputeType = 'Fast';

params.IORdecay = 0.9999;
params.smOutputRange = 1e-9;
params.noiseAmpl = 1e-17;
params.noiseConst = 1e-14;

% parameters for the gabor filters for orientation maps
params.gaborParams = defaultGaborParams;

% angles (in degrees) for orientation maps
params.oriAngles = [0 45 90 135];

% oriComputeMode: 'efficient', 'full'
% efficient: only compute orientation filters for the pyramid levels
% that are actually going to be used (based on levelParams)
% full: compute orientation filters for all pyramid levels
params.oriComputeMode = 'efficient';

% visualizationMode: 'Contour', 'ContrastModulate', or 'None'
params.visualizationStyle = 'Contour';

% map that is true foer excluded regions
params.exclusionMask = [];
