% initializeGlobal - initializes global variables
%
% initializeGlobal initializes the following global variables:
%    IS_INITIALIZED is set to 1 as a flag that initializeGlobal was called.
%    IMG_EXTENSIONS is a cell arrays with possible extensions for image files.
%    DEBUG_FID is the file identifier for debugMsg output. It is by default
%       set to 0. Set to 1 for stdout or to the fid of a text file that
%       is open for write access.
%
% See also declareGlobal, ensureDirExists, debugMsg.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function initializeGlobal(varargin)

global IS_INITIALIZED;
IS_INITIALIZED = 1;

declareGlobal;

dbstop if error;

IMG_EXTENSIONS = {'*.pgm','*.ppm','*.tif','*.tiff','*.TIF',...
                  '*.jpg','*.JPG','*.jpeg','*.png','*.PNG',...
                  '*.gif','*.GIF','*.JPEG','*.PGM','*.PPM',...
                  '*.bmp','*.BMP'};

DEBUG_FID = 0;
DBW_FID = 240.75;

fprintf('\nSaliency Toolbox (http://www.saliencytoolbox.net)\n');
fprintf('For licensing details type ''STBlicense'' at the prompt.\n\n');


