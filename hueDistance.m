% hueDistance - computes the distance in a simplified 2d color space.
%
% result = hueDistance(col_img,hueParams)
%    Computes the distance of each pixel of the
%    RGB image col_img in a 2d color space (akin to CIE (r,g)) with 
%    respect to the color model in hueParams.
%    The result is a 2d array with values between 1 and 0.
%
%    hueParams is a struct that describes a 2d Gaussian 
%    color distribution in the color space with fields:
%       muR - mean value in the CR direction.
%       sigR - standard deviation in the CR direction.
%       muG - mean value in the CG direction.
%       sigG - standard deviation in the CG direction.
%       rho - correlation coefficient between CR and CG.
%
% For details see appendix A.4 of Dirk's PhD thesis:
%    Dirk Walther (2006). Interactions of visual attention and object recognition: 
%    Computational modeling, algorithms, and psychophysics. Ph.D. thesis.
%    California Institute of Technology. 
%    http://resolver.caltech.edu/CaltechETD:etd-03072006-135433.
%
% or this book chapter:
%    Dirk B. Walther & Christof Koch (2007). Attention in 
%    Hierarchical Models of Object Recognition. In P. Cisek, 
%    T. Drew & J. F. Kalaska (Eds.), Progress in Brain Research: 
%    Computational Neuroscience: Theoretical insights into brain 
%    function. Amsterdam: Elsevier.
%
% See also makeHuePyramid, skinHueParams, dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function result = hueDistance(col_img,hueParams)

if ~isa(col_img,'double')
  col_img = im2double(col_img);
end

r = col_img(:,:,1);
g = col_img(:,:,2);
b = col_img(:,:,3);
int = r + g + b;

cr = safeDivide(r,int) - hueParams.muR;
cg = safeDivide(g,int) - hueParams.muG;

result = exp(-(cr.^2/hueParams.sigR^2/2 + ...
               cg.^2/hueParams.sigG^2/2 - ...
               cr.*cg * hueParams.rho/hueParams.sigR/hueParams.sigG));
