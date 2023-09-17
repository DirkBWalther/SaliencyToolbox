% attentuateBorders - linearly attentuates the border of data.
%
% result = attenuateBorders(data,borderSize)
%   linearly attenuates a border region of borderSize
%   on all sides of the 2d data array.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function result = attenuateBorders(data,borderSize)

result = data;
dsz = size(data);

if (borderSize * 2 > dsz(1)) borderSize = floor(dsz(1) / 2); end
if (borderSize * 2 > dsz(2)) borderSize = floor(dsz(2) / 2); end
if (borderSize < 1) return; end

bs = [1:borderSize];
coeffs = bs / (borderSize + 1);

% top and bottom
rec = repmat(coeffs',1,dsz(2));
result(bs,:) = result(bs,:) .* rec;
range = dsz(1) - bs + 1;
result(range,:) = result(range,:) .* rec;

% left and right
rec = repmat(coeffs,dsz(1),1);
result(:,bs) = result(:,bs) .* rec;
range = dsz(2) - bs + 1;
result(:,range) = result(:,range) .* rec;
