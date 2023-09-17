% checkImageSize - downsamples too large images after user confirmation.
%
% img = checkImageSize(img,mode,targetSize)
%    If any of the dimensions of img is larger than targetSize (one scalar
%    number), the function opens a dialog box asking the user if it is okay
%    to downsample the image. If the user confirms, the returned image is
%    downsampled such that its largest dimension is targetSize. Otherwise,
%    the original img is returned.
%    Possible values for mode are:
%      'GUI' - use a GUI dialog box to get user confirmation.
%      'Prompt' - ask user on the command prompt.
%      'None' - no user confirmation, downsample image if necessary.
%
% img - checkImageSize(img,mode)
%    Uses 800 as the default for targetSize.
%
% See also dataStructures, runSaliency, guiSaliency.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function img = checkImageSize(img,mode,targetSize)

if isempty(img)
  return;
end

if isempty(img.data)
  return;
end

if (nargin < 3)
  targetSize = 800;
end

oldSize = img.size(1:2);
mx = max(oldSize);
if (mx > targetSize)
  newSize = round(oldSize/mx * targetSize);
  question = 'Is it okay to downsample the image?';
  text = {sprintf('The image is fairly large (%d x %d pixels).',oldSize(2),oldSize(1)),'',...
          'For processing in the SaliencyToolbox it is recommended to downsample',...
          sprintf('the image to %d x %d pixels.',newSize(2),newSize(1)),'',...
          question,''};
  switch mode
    case 'GUI'
      reply = questdlg(text,'Downsample image?','Yes','No','Yes');
      doit = strcmp(reply,'Yes');
    case 'Prompt'
      for t = 1:length(text)-2
        if ~isempty(text{t})
          fprintf('%s\n',text{t});
        end
      end
      reply = input([question ' [y]|n '],'s');
      doit = ismember(reply,{'','y','Y','yes','Yes'});
    case 'None'
      doit = 1;
    otherwise
      debugMsg(['Unknown mode: ' mode]);
  end
  if doit
    img.data = imresize(img.data,newSize);
    img.size = size(img.data);
  end
end
