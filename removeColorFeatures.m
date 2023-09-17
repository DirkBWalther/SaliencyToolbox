% removeColorFeatures - removes color features from the saliency
% parameters.
%
% params = removeColorFeatures(params)
%   removes all features from params that require a color image.
%
% params = removeColorFeatures(params,0)
%   suppresses the warning.
%
% See also defaultSaliencyParams, runSaliency, dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function params = removeColorFeatures(params,fid)

if nargin < 2
  fid = 1;
end

colorTypes = {'Color','Hue','Skin'};

numFeats = length(params.features);
idx = [1:numFeats];

for f = 1:numFeats
  if ismember(params.features{f},colorTypes)
    if (fid ~=0)
      fprintf(fid,['Warning: Trying to use feature ''' params.features{f} '''\n' ...
                   'for a non-color image. Skipping the feature.\n\n']);
    end
    idx = setdiff(idx,f);
  end
end

% actually remove the features and their weights
params.features = params.features(idx);
params.weights = params.weights(idx);
