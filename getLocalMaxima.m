% getLocalMaxima - returns statistics over local maxima.
%
% [lm_avg,lm_num,lm_sum] = getLocalMaxima(data,thresh)
%    Returns the average value (lm_avg), the number (lm_num),
%    and the sum (lm_sum) of local maxima in data that exceed thresh.
%
% See also maxNormalizeStd.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function [lm_avg, lm_num, lm_sum] = getLocalMaxima(data, thresh)

    refData = data(2:end-1,2:end-1);
    localMax = (refData >= data(1:end-2,2:end-1)) & ...
               (refData >= data(3:end,2:end-1)) & ...
               (refData >= data(2:end-1,1:end-2)) & ...
               (refData >= data(2:end-1,3:end)) & ...
               (refData >= thresh);
    maxData = refData(localMax(:));
    lm_avg = mean(maxData);
    lm_sum = sum(maxData);
    lm_num = numel(maxData);
end