% initializeImage - initializes an image structure.
%
% [Image,err] = initializeImage(filename);
%    Initializes an Image structure given an image file name.
%    If there is an error in reading the file, it is returned
%    in err.
%
% Image = initializeImage(imgData);
%    Initialize an Image structure with the image
%    content instead of the file name.
%
% [Image,err] = initializeImage(filename,imgData);
%    Initialize an Image structure with both the image
%    content and the file name.
%
% [Image,err] = initializeImage(...,type);
%    Gives Image the text label type. Default is 'unknown'.
%
% The Image structure has the following members:
%   filename - the filename 
%   data - the actual content of the image
%          Each image structure has to contain the filename or the data
%          field. It can have both.
%   type - some text label
%   size - the size of the image
%   dims - the number of dimensions of the image (2 or 3)
%   date - the time and date this structure was created
%
% See also dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function [Img,err] = initializeImage(varargin);

declareGlobal;
err = [];

if (nargin < 1)
  error('Must have at least one argument!');
elseif (nargin < 2)
  switch class(varargin{1})
    case 'char'
      Img.filename = varargin{1};
      Img.data = NaN;
      Img.type = 'unknown';
    case {'uint8','double'}
      Img.filename = NaN;
      Img.data = varargin{1};
      Img.type = 'unknown';
    otherwise
      error(['Don''t know how to handle data of class' class(varargin{1})]);
  end
elseif (nargin < 3)
  switch class(varargin{1})
    case 'char'
      Img.filename = varargin{1};
      switch class(varargin{2})
        case 'char'
          Img.data = NaN;
          Img.type = varargin{2};
        case {'uint8','double'}
          Img.data = varargin{2};
          Img.type = 'unknown';
        otherwise
          error('Don''t know how to handle image data of class %s.',class(varargin{2}));  
      end
      
    case {'uint8','double'}
      Img.filename = NaN;
      Img.data = varargin{1};
      Img.type = varargin{2};
      
    otherwise
      error(['Don''t know how to handle data of class' class(varargin{1})]);
  end
else
  Img.filename = varargin{1};
  Img.data = varargin{2};
  Img.type = varargin{3};
end

if (isnan(Img.data))
  try
    im = imread(Img.filename);
  catch
    Img = [];
    err = lasterror;
    if (nargout < 2)
      rethrow(err);
    end
    return;
  end
  Img.data = im;
  Img.size = size(im);
else
  Img.size = size(Img.data);
end

Img.dims = length(Img.size);
Img.date = clock;
