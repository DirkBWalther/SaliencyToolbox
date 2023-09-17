% diskIOR - applies disk-shaped inhibition of return.
%
% wta = diskIOR(oldWTA,winner,saliencyParams)
%    Applies disk-shaped inhibition of return to the
%    winner-take-all structure oldWTA at position winner
%    and returns the result as wta. The radius of the
%    disk is taken from params.foaSize.
%
% See also applyIOR, shapeIOR, initializeWTA, defaultSaliencyParams, dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function wta = diskIOR(oldWTA,winner,params)

if (params.foaSize < 0)
  error(['invalid params.foaSize: ' num2str(params.foaSize)]);
end  

wta = oldWTA;

xx = [1:size(wta.sm.V,2)] - winner(2);
yy = [1:size(wta.sm.V,1)] - winner(1);
[x,y] = meshgrid(xx,yy);
d = x.*x + y.*y;

pampl = 0.1 * wta.sm.V(winner(1),winner(2));
mampl = 1e-4 * pampl;

% this exponent should be '+1' for Matlab notation and '-1', because
% foaSize is interpreted as radius here, not as diameter
psdev = 0.3 * params.foaSize / 2^params.levelParams.mapLevel;

msdev = 4.0 * psdev;
g = pampl * exp(-0.5 * d / psdev^2) - ...
    mampl * exp(-0.5 * d / msdev^2);

wta.sm.Ginh = wta.sm.Ginh + g;
