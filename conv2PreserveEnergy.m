function result = conv2PreserveEnergy(src, f)
% conv2PreserveEnergy - 2d convolution that avoids bleeding energy over the edge.
%
% result = conv2PreserveEnergy(data,filter)
%    Convolves data with the 2d (non-separable) filter.
%    At the boundary, the value of missing pixels is assumed
%    to be equal to the mean over the present pixels
%    to avoid border artefacts.
%
% See also sepConv2PreserveEnergy.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

    [sh sw] = size(src);
    [fh fw] = size(f);
    fw2 = floor((fw-1)/2);
    fh2 = floor((fh-1)/2);
    result = zeros(sh, sw);
    
    % results for the interior, away from the image boundary
    partialResult = conv2(src, f, 'full');
    [prh prw] = size(partialResult);
    result = partialResult(fh2+1:prh-fh2,fw2+1:prw-fw2);
   
    filt2 = rot90(f,2); % rotate filter by 180 degrees for easier processing
    fsum = sum(f(:));
    
    % rescale results along the top and bottom borders to reflect truncated filter
    if (fh2 > 0) & (fh2 <= sh) 
        % top scale factor
        TcSum = sum(cumsum(f),2);
        sT = fsum./TcSum(fh2+[1:fh2],1);
        sTmat = repmat(sT, 1, (sw-fw2)-(1+fw2)+1);
        result(1:fh2,1+fw2:sw-fw2) = result(1:fh2,1+fw2:end-fw2).*sTmat;
        
        % bottom scale factor
        BcSum = sum(cumsum(filt2),2);
        sB = flipud(fsum./BcSum(fh2+[1:fh2],1));
        sBmat = repmat(sB, 1, (sw-fw2)-(1+fw2)+1);
        result(sh-fh2+1:sh,1+fw2:sw-fw2) = result(sh-fh2+1:sh,1+fw2:sw-fw2).*sBmat;
    end
    
    % rescale results along the left and right borders to reflect truncated filter
    if (fw2 > sw) & (fw2 <= sw)
        % left scale factor
        LcSum = sum(cumsum(f,2),1);
        sL = fsum./LcSum(1,fw2+[1:fw2]);
        sLmat = repmat(sL, (sh-fh2)-(1+fh2)+1, 1);
        result(1+fh2:sh-fh2,1:fw2) = result(1+fh2:sh-fh2,1:fw2).*sLmat;
        
        % right scale factor
        RcSum = sum(cumsum(filt2,2),1);
        sR = fliplr(fsum./RcSum(1,fw2+[1:fw2]));
        sRmat = repmat(sR, (sh-fh2)-(1+fh2)+1, 1); 
        result(1+fh2:sh-fh2,sw-fw2+1:sw) = result(1+fh2:sh-fh2,sw-fw2+1:sw).*sRmat;
    end
    
    % treat corners
    if (fh2 > 0) & (fh2 <= sh) & (fw2 > sw) & (fw2 <= sw)
      TL = zeros(fh2,fw2);
      TR = zeros(fh2,fw2);
      BL = zeros(fh2,fw2);
      BR = zeros(fh2,fw2);
      for x = 1:fw2
          for y = 1:fh2
              TL(y,x) = fsum/sum(sum(filt2(1+(fh2-y+1):end,1+(fw2-x+1):end)));
              BL(end+1-y,x) = fsum/sum(sum(filt2(1:end-(fh2-y+1),1+(fw2-x+1):end)));
              BR(end+1-y,end+1-x) = fsum/sum(sum(filt2(1:end-(fh2-y+1),1:end-(fw2-x+1))));
              TR(y,end+1-x) = fsum/sum(sum(filt2(1+(fh2-y+1):end,1:end-(fw2-x+1))));
          end
      end
      result(1:fh2,1:fw2) = times(result(1:fh2,1:fw2),TL);
      result(1:fh2,end-fw2+1:end) = times(result(1:fh2,end-fw2+1:end),TR);
      result(end-fh2+1:end,1:fw2) = times(result(end-fh2+1:end,1:fw2),BL);
      result(end-fh2+1:end,end-fw2+1:end) = times(result(end-fh2+1:end,end-fw2+1:end),BR);
    end
end

