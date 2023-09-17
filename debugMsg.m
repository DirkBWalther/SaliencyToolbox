% debugMsg displays a debug message with line number and filename.
%
% debugMsg(message) 
%    writes the string message to the file that is specified by the 
%    global variable DEBUG_FID; if DEBUG_FID is 0, no message is written; 
%    if DEBUG_FID is 1, the message is written to stdout; 
%    for other values it is assumed that DEBUG_FID is the valid 
%    file identifier for an open and writable text file.
%
% debug(message,object) 
%    writes the message and information about object, which can be:
%       a map structure - min, avg, and max are written out.
%       a pyramid structure - the min, avg, and max for each
%                             level map are written out.
%       a numeric array - the min, avg, and max are written out.
%
% See also dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net
  
function debugMsg(message,varargin)

declareGlobal;

if (DEBUG_FID == 0)
  return
end

st = dbstack;

msg = sprintf('%s at %i: %s',st(2).file,st(2).line,message);

if (~isempty(varargin))
  
  % is struct?
  if isstruct(varargin{1})
  fnames = fieldnames(varargin{1});
  
    % is map?
    if (length(strmatch('data',fnames)) > 0)
      map = varargin{1};
      lm = length(map);
      if (lm > 1)
        fprintf(DEBUG_FID,'%s\n',msg);
      end
      for m = 1:lm
        mx = max(map(m).data(:));
        mn = min(map(m).data(:));
        av = mean(map(m).data(:));
        if (lm == 1)
          fprintf(DEBUG_FID,'%s %s: [%g; %g; %g]\n',...
	          msg,map(m).label,mn,av,mx);
        else
          fprintf(DEBUG_FID,'%s\t%s: [%g; %g; %g]\n',...
	          msg,map(m).label,mn,av,mx);
        end
      end
    elseif (length(strmatch('levels',fnames)) > 0)
      pyr = varargin{1};
      fprintf(DEBUG_FID,'%s pyramid %s:\n',msg,pyr.label);
      for i=1:length(pyr.levels)
        mx = max(pyr.levels(i).data(:));
        mn = min(pyr.levels(i).data(:));
        av = mean(pyr.levels(i).data(:));
        fprintf(DEBUG_FID,'%s\tlevel %i: [%g; %g; %g]\n',msg,i,mn,av,mx);
      end
    end
  elseif isnumeric(varargin{1})
    % numeric -> print mn,av,mx
    fprintf(DEBUG_FID,'%s: [%g; %g; %g]\n',msg,min(varargin{1}(:)),...
            mean(varargin{1}(:)),max(varargin{1}(:)));
  end
else
  fprintf(DEBUG_FID,'%s\n',msg); 
end
