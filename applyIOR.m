% applyIOR - applies inhibition of return.
%
% wta = applyIOR(oldWTA,winner,saliencyParams)
%    Applies inihibition of return to the winner-take-all
%    network as specified in saliencyParams.IORtype.
%
% wta = applyIOR(oldWTA,winner,saliencyParams,shapeData)
%    For saliencyParams.IORtype = 'shape', the shapeData
%    from estimateShape are needed.
%
% See also diskIOR, shapeIOR, estimateShape, runSaliency, dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function wta = applyIOR(oldWTA,winner,params,varargin)

switch params.IORtype
  case 'None'
    wta = oldWTA;
  case 'disk'
    wta = diskIOR(oldWTA,winner,params);
  case 'shape'
    if (isempty(varargin))
      error('shapeIOR requires shapeData as an additional argument!');
    end
    if (isempty(varargin{1}))
      wta = diskIOR(oldWTA,winner,params);
    else
      wta = shapeIOR(oldWTA,winner,params,varargin{1});
    end
  otherwise
    error(['Unknown IORtype: ' params.IORtype]);
end
    
