% STBgenerateDoc - generates html documentation.
%    This is a wrapper for the m2html program with settings
%    that work for the SaliencyToolbox. You must have m2html
%    in the executable path, and you must change to the 
%    SaliencyToolbox directory before excuting this function.
%
% For m2html see: http://www.artefact.tk/software/matlab/m2html/

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.txt document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function STBgenerateDoc

if isempty(which('m2html'))
  fprintf('Please install m2html and add it to the executable path.\n');
  fprintf('http://www.artefact.tk/software/matlab/m2html/\n');
  return;
end

currDir = pwd;
[path,dirname] = fileparts(fileparts(which(mfilename)));

cd(path);

m2html('mfiles',dirname,...
       'htmldir',[dirname,filesep,'doc',filesep,'mdoc'],...
       'recursive','off');

cd(currDir);

   