% gaussian - returns a 1d Gaussian kernel.
%
% kernel = gaussian(peak,sigma,maxhw)
%    Returns a 1d Gaussian kernel with peak as the value
%    at the maximum and sigma as the standard deviation (in pixels).
%    The half width (hw) of the kernel is determined by where the
%    Gaussian drops off to 1 % of the peak value, but
%    is bounded by maxhw (set to 0 for no bounding). 
%    The kernel will be of length: 2 * hw + 1.
%
% kernel = gaussian(peak,sigma,maxhw, treshPercent)
%    Use threshPercent (in % of peak value) instead of 1 %
%    to determine the half width.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function kernel = gaussian(peak,sigma,maxhw,varargin)

if isempty(varargin)
  threshPercent = 1;
else
  threshPercent = varargin{1};
end

hw = floor(sigma * sqrt(-2 * log(threshPercent / 100)));

% cut the half width off if it is too large
if ((maxhw > 0) & (hw > maxhw)) 
  hw = maxhw; 
end

% get the right peak value (if peak = 0, normalize area to 1)
if (peak == 0) 
  peak = 1 / (sigma * sqrt(2*pi)); 
end

% build the kernel
sig22 = -0.5 / (sigma * sigma);
tmp = peak * exp(- [1:hw].^2 / (2*sigma*sigma));
kernel = [tmp(hw:-1:1) peak tmp];
