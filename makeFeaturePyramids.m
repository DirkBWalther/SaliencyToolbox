% makeFeaturePyramids - creates a pyramid for featureType.
%
% pyrs = makeFeaturePyramids(img,featureType,salParams,varargin)
%    Creates a feature pyramid with the parameters:
%      img: the Image structure for the source image.
%      featureType: what feature ('Intensity','Color','Orientation',
%                  'Hue','Skin','TopDown');
%      salParams: the saliency parameters for this operation;
%      varargin: additional info, depending on the featureType:
%        'Orientation': varargin{1} may hold an auxiliary 
%                       intensity pyramid;
%        'TopDown': varargin{1} must hold a vector of auxiliary 
%                   maps for top-down attention;
%        'Hue': varargin{1} must contain hueParams.
%
%    pyrs: a vector of pyramids of type featureType.
%
% See also makeSaliencyMap, dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function pyrs = makeFeaturePyramids(img,featureType,salParams,varargin)

% These feature types require color images:
colorTypes = {'Color','Hue','Skin'};
if (ismember(featureType,colorTypes) && img.dims == 2)
  % not a color image for color type? terminate with error
  fprintf(['Feature ''' featureType ''' requires a color image!\n' ...
           'Use a color image or remove this feature from the\n' ...
           'saliency parameters!\n']);
  error('Could not process image.');
end

switch featureType
  
  case {'Intensity','Intensities'}
    pyrs = makeIntensityPyramid(img,salParams.pyramidType);

  case 'Color'
    pyrs(1) = makeRedGreenPyramid(img,salParams.pyramidType);
    pyrs(2) = makeBlueYellowPyramid(img,salParams.pyramidType);

  case {'Orientation','Orientations'}
    % varargin{1} could be an intensity pyramid, otherwise have to make one
    intPyr = [];
    if (~isempty(varargin))
      if (strcmp('Intensity',varargin{1}.label))
        intPyr = varargin{1};
      end
    end
    if (isempty(intPyr))
      intPyr = makeIntensityPyramid(img,salParams.pyramidType);
    end

    if isfield(salParams,'oriComputeMode')
      switch salParams.oriComputeMode
        case 'efficient'
          oriLevels = salParams.levelParams.minLevel:...
                      min(salParams.levelParams.maxLevel + salParams.levelParams.maxDelta,length(intPyr.levels));
          oriLevels = union(oriLevels,salParams.levelParams.mapLevel);
        case 'full'
          oriLevels = 1:length(intPyr.levels);
        otherwise
          error(['Unknown oriComputeMode: ' salParams.oriComputeMode]);
      end
    else
      oriLevels = 1:length(intPyr.levels);
    end

    for ori = 1:length(salParams.oriAngles)
      pyrs(ori) = makeOrientationPyramid(intPyr,...
                  salParams.gaborParams,salParams.oriAngles(ori),oriLevels);
    end
      
  case 'Hue'
    % varargin{1} must contain the hueParams
    if (isempty(varargin))
      error('varargin{1} must contain hueParams for Hue Channel');
    end 
    % varargin{2} might contain an alternative label
    if (length(varargin >= 2))
      pyrs = makeHuePyramid(img,salParams.pyramidType,varargin{1},varargin{2});
    else
      pyrs = makeHuePyramid(img,salParams.pyramidType,varargin{1});
    end
      
  case 'Skin'
    pyrs = makeHuePyramid(img,salParams.pyramidType,skinHueParams,'Skin');
    
  case 'TopDown'
    if isempty(varargin)
      error('varargin{1} must contain a vector of TopDown maps');
    end
    % this is a dummy function that simply copies the auxiliary pyramids
    pyrs = varargin{1};
      
  otherwise
    error(['Unknown feature: ' featureType]);
end
