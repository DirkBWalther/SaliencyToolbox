% loadImage - returns the imgData for the Image structure
%
% imgData = loadImage(Image)
%    Returns the imgData from one of two sources:
%    (1) If Image.data is valid, it is returned after conversion 
%        to double (if necessary). 
%    (2) Otherwise, the image is loaded from Image.filename, 
%        converted to double and returned.
%
% See also initializeImage, dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function imgData = loadImage(Image)

if isa(Image.data,'uint8')
  imgData = im2double(Image.data);
elseif isnan(Image.data)
  imgData = im2double(imread(Image.filename));
else
  imgData = Image.data;
end
