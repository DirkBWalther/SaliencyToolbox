% computeAllSaliencyMaps - computes the saliency maps for many images.
%
% computeAllSaliencyMaps(imageFile,salmapFile,salParams,log_fid)
%    Computes the saliency maps for all images in imageFile.
%    This function is useful for batch processing many images.
%
%    imageFile - the filename of a .mat file with a vector of image
%       structures called 'images'. 
%    salmapFile - the file name of the file where the saliency maps
%       should be saved.
%    salParams - the parameters for computing the saliency maps.
%    log_fid - a file identifier to write logging information to
%              (0 for no log info, 1 for stdout).
%
% See also batchSaliency, defaultSaliencyParams, makeSaliencyMap, initializeGlobal.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function computeAllSaliencyMaps(imageFile,salmapFile,salParams,fid)

declareGlobal;

fprintf(fid,'Starting %s on %s at %s.\n',mfilename,imageFile,timeString);

tmp = load(imageFile);
names = fieldnames(tmp);
img = getfield(tmp,names{1});
numImg = length(img);

for i = 1:numImg
  fprintf(fid,'Processing image %d of %d ...\n',i,numImg);
  SaliencyMap(i) = makeSaliencyMap(img(i),salParams);
end

save(salmapFile,'SaliencyMap');
fprintf(fid,'Saved results in %s at %s.\n',salmapFile,datestr(clock));
