% declareGlobal - declares global variables.
%
% declareGlobal declares the global variables:
%     IS_INITIALIZED BASE_DIR IMG_DIR DATA_DIR TMP_DIR
%     PD IMG_EXTENSIONS DEBUG_FID and initializes them,
%     if they are not yet initialized.
%
% See also initializeGlobal.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

global IS_INITIALIZED IMG_EXTENSIONS DEBUG_FID;

if isempty(IS_INITIALIZED)
  initializeGlobal;
end
