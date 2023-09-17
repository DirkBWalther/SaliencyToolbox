% maxNormalize - normalizes a set of maps according to params.
%
% resultMap = maxNormalize(maps,salParams)
%    Normalizes all maps according to the normalization
%    method specified in salParams.normtype.
%
% resultMap = maxNormalize(maps,salParams,minmax)
%    Specify a dynamic range for the initial maximum 
%    normalization of the input data (default: [0 10]).
%    The special value minmax = [0 0] means that initial
%    maximum normalization is omitted.
%
% See also maxNormalizeLocalMax, maxNormalizeIterative, makeSaliencyMap, defaultSaliencyParams.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function result = maxNormalize(maps,params,varargin)

if (length(varargin) >= 1) mima = varargin{1}; 
else mima = [0 10]; end

for m = 1:length(maps)

  debugMsg('',maps(m));

  result(m) = maps(m);

  if strcmp(maps(m).label,'empty')
    debugMsg('Empty map - no normalization.');
    continue;
  end
  
  switch(params.normtype)
    case 'None'
      result(m).data = normalizeImage(maps(m).data,mima);
    case {'Standard','LocalMax'}
      result(m).data = maxNormalizeLocalMax(maps(m).data,mima);
    case 'Iterative'
      result(m).data = maxNormalizeIterative(maps(m).data,params.numIter,mima);
    otherwise
      error(['Unknown normalization type: ' params.normtype]);
  end

  debugMsg(sprintf('%s [%3.1f,%3.1f]',params.normtype,mima(1),mima(2)),result(m));

end
