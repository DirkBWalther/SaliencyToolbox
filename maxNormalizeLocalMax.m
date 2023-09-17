% maxNormalizeLocalMax - normalization based on local maxima.
%
% result = maxNormalizeLocalMax(data)
%    Normalize data by multiplying it with 
%    (max(data) - avg(localMaxima))^2 as described in:
%    L. Itti, C. Koch, E. Niebur, A Model of Saliency-Based 
%    Visual Attention for Rapid Scene Analysis, IEEE PAMI, 
%    Vol. 20, No. 11, pp. 1254-1259, Nov 1998.
%
% result = maxNormalizeLocalMax(data,minmax)
%    Specify a dynamic range for the initial maximum 
%    normalization of the input data (default: [0 10]).
%    The special value minmax = [0 0] means that initial
%    maximum normalization is omitted.
%
% See also maxNormalize, maxNormalizeIterative, makeSaliencyMap.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function result = maxNormalizeLocalMax(data,varargin)

if (length(varargin) >= 1) minmax = varargin{1}; 
else minmax = [0 10]; end

data = normalizeImage(clamp(data,0),minmax);

if (minmax(1) == minmax(2))
  thresh = 1;
  globalMax = max(data(:));
else
  thresh = minmax(1) + (minmax(2) - minmax(1)) / 10;
  globalMax = minmax(2);
end

[lm_avg,lm_num,lm_sum] = getLocalMaxima(data,thresh);

if (lm_num > 1)
  result = data * (globalMax - lm_avg)^2;
elseif (lm_num == 1)
  result = data * globalMax^2;
else
  error('Could not find any local maxima.');
end
