% sepConv2PreserveEnergy - energy preserving 2d convolution with separable filter
%
% result = sepConv2PreserveEnergy(yFilter,xFilter,data)
%
%    Convolves data with the separable filters xFilter and
%    yFilter. For border elements, the filters are truncated
%    and the filter energy is renormalized to avoid bleeding
%    over the edge. The result has the same size as data.
%
% See also conv2PreserveEnergy, maxNormalizeIterative.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function result = sepConv2PreserveEnergy(filter1,filter2,data)

[sd1,sd2] = size(data);

% 2d convolution with zero padding from Matlab
result = conv2(filter1,filter2,data,'same');

% filter length and half-length for the vertical filter
fl1 = length(filter1);
fl1b = floor((fl1-1)/2);

% cumulative sums forward and backward
fc1a = cumsum(filter1);
fc1b = cumsum(filter1(end:-1:1));
fs1 = sum(filter1);

% Is data field very small?
if (fl1 > sd1)
  % very small -> need to find the various sums of filter
  % elements used for each convolution
  tmp = [zeros(1,fl1) fc1a(:)' fs1*ones(1,fl1)];
  range = fl1+fl1b+(1:sd1);
  ff1 = repmat((tmp(range)-tmp(range-sd1))',1,sd2);
  
  % normalize result by (actual filter size / full filter size)
  result = result * fs1 ./ ff1;
else
  % border with incomplete filter coverage at top
  ff1a = repmat(fc1a(fl1b+1:end-1)',1,sd2);
  result(1:fl1b,:) = result(1:fl1b,:) * fs1 ./ ff1a;
  
  % border with incomplete filter coverage at bottom
  ff1b = repmat(fc1b(fl1b+1:end-1)',1,sd2);
  result(end:-1:end-fl1b+1,:) = result(end:-1:end-fl1b+1,:) * fs1 ./ ff1b;
end

% now the same again for the horizontal filter

% filter length and half-length
fl2 = length(filter2);
fl2b = floor((fl2-1)/2);

% cumulative sums forward and backward
fc2a = cumsum(filter2);
fc2b = cumsum(filter2(end:-1:1));
fs2 = sum(filter2);

% Is data field very small?
if (fl2 > sd2)
  % very small -> need to find the various sums of filter
  % elements used for each convolution
  tmp = [zeros(1,fl2) fc2a(:)' fs2*ones(1,fl2)];
  range = fl2+fl2b+(1:sd2);
  ff2 = repmat((tmp(range)-tmp(range-sd2)),sd1,1);
  
  % normalize result by (actual filter size / full filter size)
  result = result * fs2 ./ ff2;
else
  % border with incomplete filter coverage at the left
  ff2a = repmat(fc2a(fl2b+1:end-1),sd1,1);
  result(:,1:fl2b) = result(:,1:fl2b) * fs2 ./ ff2a;
  
  % border with incomplete filter coverage at the right
  ff2b = repmat(fc2b(fl2b+1:end-1),sd1,1);
  result(:,end:-1:end-fl2b+1) = result(:,end:-1:end-fl2b+1) * fs2 ./ ff2b;
end
