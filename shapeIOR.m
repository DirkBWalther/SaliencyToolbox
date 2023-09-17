% shapeIOR - applies shape-based inhibition of return.
%
% wta = shapeIOR(wta,winner,saliencyParams,shapeData)
%    Applies shape-based inhibition of return to the wta
%    winner-take-all network at the winner location,
%    based on the settings in saliencyParams and on the
%    shape information in shapeData.
%
% See also estimateShape, applyIOR, diskIOR, defaultSaliencyParams.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function wta = shapeIOR(wta,winner,params,shapeData)

% is shape estimator map valid? if not, revert to diskIOR
if (max(shapeData.binaryMap.data(:)) == 0)
  wta = diskIOR(wta,winner,params);
  return
end

ampl = 0.1 * wta.sm.V(winner(1),winner(2));

if isequal(size(shapeData.iorMask.data),size(wta.sm.V))
  binMap = shapeData.iorMask.data;
else
  binMap = imresize(shapeData.iorMask.data,size(wta.sm.V),'nearest');
end

wta.sm.Ginh = wta.sm.Ginh + ampl * binMap;
