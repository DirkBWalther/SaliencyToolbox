% gaussianSubsample - smooths and subsamples image.
%
% result = gaussianSubsample(image)
%    Convolves image with a 6x6 separable Gaussian kernel
%    and subsamples by a factor of two. 
%
% See also makeDyadicPyramid, makeSqrt2Pyramid, makeGaussianPyramid, sepConv2PreserveEnergy.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function result = gaussianSubsample(img)
% need the extra trailing 1 for backward compatibility with the old mex version
% the particular values are also for backward compatibility
filter = [1,5,10,10,5,1,1]; 
filter = filter/sum(filter);

[h,w] = size(img);

if min(h,w) > 3
  % big image - use straight-forward method
  convResult = sepConv2PreserveEnergy(filter,filter,img);
  horResult = convResult(:,[2:2:end]-1);
  result = horResult([2:2:end]-1,:);
else
  % Image is small along at least one dimension.
  % Need to treat dimensions separately.

  % Horizontal pass
  if w <= 1
    % nothing to do
    horResult = img;
  elseif w == 2
    % kernel: [1,1]
    horResult = mean(img,2);
  elseif w == 3
    % kernel: [1,2,1]
    horResult = mean(img(:,[1,2,2,3]),2);
  else
    % horizontal convolution
    horResult = sepConv2PreserveEnergy(1,filter,img);

    % horizontal subsampling
    horResult = horResult(:,1:2:end-1);
  end

  % Vetical pass
  if h <= 1
    % nothing to do
    result = horResult;
  elseif h == 2
    % kernel: [1,1]
    result = mean(horResult,1);
  elseif h == 3
    % kernel: [1,2,1]
    result = mean(horResult([1,2,2,3],:),1);
  else
    % vertical convolution
    verResult = sepConv2PreserveEnergy(filter,1,horResult);

    % vertical subsampling
    result = verResult(1:2:end-1,:);
  end
end

