% maxNormalizeIterative - normalize data with the an iterative algorithm.
%
% result = maxNormalizeIterative(data,numIter)
%    Normalize the data with the iterative 
%    normalization algorithm described in:
%    L. Itti, C. Koch, A saliency-based search mechanism for overt 
%    and covert shifts of visual attention, Vision Research, 
%    Vol. 40, No. 10-12, pp. 1489-1506, May 2000.
%       data: a 2d input array
%       numIter: number of iterations
%       result: the normalized image
%
% result = maxNormalizeIterative(data,numIter,minmax)
%    Specify a dynamic range for the initial maximum 
%    normalization of the input data (default: [0 10]).
%    The special value minmax = [0 0] means that initial
%    maximum normalization is omitted.
%
% See also maxNormalize, maxNormalizeLocalMax, makeSaliencyMap.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function result = maxNormalizeIterative(data,numIter,varargin)

% a few parameters for the convolution filters
iterInhi = 2.0;
iterCoEx = 0.5;
iterCoIn = 1.5;
iterExSig = 2;
iterInSig = 25;

if (length(varargin) >= 1) minmax = varargin{1}; 
else minmax = [0 10]; end
  
result = normalizeImage(clamp(data,0),minmax);

% make 1d Gaussian kernels for excitation and inhibition
sz = max(size(result));
maxhw = max(0,floor(min(size(result))/2) - 1);
esig = sz * iterExSig * 0.01;
isig = sz * iterInSig * 0.01;
gExc = gaussian(iterCoEx/(esig*sqrt(2*pi)),esig,maxhw);
gInh = gaussian(iterCoIn/(isig*sqrt(2*pi)),isig,maxhw);

% go through the normalization iterations
for iter = 1:numIter
  
  % get the excitatory and inhibitory receptive fields
  excit = sepConv2PreserveEnergy(gExc,gExc,result);
  inhib = sepConv2PreserveEnergy(gInh,gInh,result);
  
  % global inhibition to prevent explosion of the map activity
  globinhi = 0.01 * iterInhi * max(result(:));
  
  % putting all the terms together and clamping them
  result = clamp((result + excit - inhib - globinhi), 0);
end
