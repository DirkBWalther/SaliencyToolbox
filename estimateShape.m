% estimateShape - estimates the shape of the attended proto-object region.
%
% shapeData = estimateShape(salmap,saliencyData,winner,saliencyParams)
%    Estimates the shape of the attended proto-object region from the saliencyData:
%
%    salmap: the saliency map as returned by makeSaliencyMap.
%    saliencyData: the saliencyData as returned by makeSaliencyMap.
%    winner: the winning location in saliency map coordinates.
%    saliencyParams: the necesary parameters.
%
%    shapeData: structure containing information about the shape of
%    the attended regions, with the following fields:
%       origImage: the Image structure for the source image.
%          winner: the winning location in saliency map coordinates.
%      winningMap: the map for the most salient feature at the winner location.
%         iorMask: the mask used for shape-based inhibition of return.
%       binaryMap: a binary map of the attended region.
%    segmentedMap: the winning map segmented by the binary map.
%        shapeMap: a smoothed version of segmentedMap.
%            date: the time and date of the creation of this structure.
%
%    If finding an appropriate map for segmentation failed, an empty
%    shapeData structure is returned.
%
% The possible params.shapeModes for shape estimation are:
%     'None': no shape processing.
%     'shapeSM': use the saliency map.
%     'shapeCM': use the conspicuity map with the largest contribution
%                to the saliency map at the attended location.
%     'shapeFM': use the feature map with the largest contribution
%                to that conspicuity map.
%    'shapePyr': use the pyramid level (center or surround level) with
%                the largest ontribution to that feature map.
%
% For details of this method see:
%      Walther, D., and Koch, C. (2006). Modeling attention to salient 
%      proto-objects. Neural Networks 19, pp. 1395-1407.
%
% See also makeSaliencyMap, evolveWTA, dataStructures, runSaliency, 
%          applyIOR, shapeIOR, defaultSaliencyParams.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function shapeData = estimateShape(salmap,saliencyData,winner,params)

if strcmpi(params.shapeMode,'None')
  shapeData = [];
  return
end

shapeData.origImage = salmap.origImage;
shapeData.winner = winner;

tmp1 = cat(1,saliencyData.CM);
tmp2 = cat(3,tmp1.data);
[mx,CMidx] = max(tmp2(winner(1),winner(2),:));

% first default: winning map is saliency map
winMap = salmap;
winPos = {winner};

% need to go deeper into the maps?
if ((mx > 0) & ~strcmp(params.shapeMode,'shapeSM'))
  
  % find the biggest contributing conspicuity map
  CMidx = CMidx(randi(length(CMidx)));
  tmp1 = cat(1,saliencyData(CMidx).FM(:));
  tmp2 = cat(3,tmp1.data);
  [mx,FMidx] = max(tmp2(winner(1),winner(2),:));
  
  % found our winning conspicuity map
  winMap(end+1) = saliencyData(CMidx).CM;
  winPos{end+1} = winner;

  % need to go deeper?
  if ((mx > 0) & ~strcmp(params.shapeMode,'shapeCM'))
    
    % our next bet are the feature maps that contribute
    % to the wining conspicuity map
    FMidx = FMidx(randi(length(FMidx)));
    winMap(end+1) = saliencyData(CMidx).FM(FMidx);
    winPos{end+1} = winner;
    
    % need to go deeper still?
    if (strcmp(params.shapeMode,'shapePyr'))
      
      % now we compare the contributing center and surround maps
      cen = saliencyData(CMidx).csLevels(FMidx).centerLevel;
      sur = saliencyData(CMidx).csLevels(FMidx).surroundLevel;
      [pyrIdx,tmp] = ind2sub(size(saliencyData(CMidx).FM),FMidx);
      cenMap = saliencyData(CMidx).pyr(pyrIdx).levels(cen);
      surMap = saliencyData(CMidx).pyr(pyrIdx).levels(sur);
      
      % extract the values of the cen and sur maps at the winner location
      wCM = size(saliencyData(CMidx).CM.data,2);
      cenWin = round(winner/wCM * size(cenMap.data,2));
      surWin = round(winner/wCM * size(surMap.data,2));
      cenWin = max(min(cenWin,size(cenMap.data)),[1 1]);
      surWin = max(min(surWin,size(surMap.data)),[1 1]);
      cenVal = cenMap.data(cenWin(1),cenWin(2));
      surVal = surMap.data(surWin(1),surWin(2));
      
      % compare center and surround and store the winner
      if (abs(cenVal) > abs(surVal) & (min(size(cenMap.data)) > 7))
        winMap(end+1) = cenMap;
        winVal = cenVal;
        winPos{end+1} = cenWin;
      else
        winMap(end+1) = surMap;
        winVal = surVal;
        winPos{end+1} = surWin;
      end
      
      % renormalize the cen or sur map values for better segmentation
      winMap(end).data = (1 - abs(winMap(end).data - winVal) / winVal).^2;
    end    
  end
end

% now we have extracted all the maps we need
debugMsg(winMap(end).label)
debugMsg(sprintf('Value at winning location: %g',...
         winMap(end).data(winPos{end}(1),winPos{end}(2))));
gotMap = 0;

% let's see who behaves nicely for segmentation
for idx = length(winMap):-1:1
  switch params.segmentComputeType
    case 'Fast'
      binMap = fastSegmentMap(winMap(idx),winPos{idx});
    case 'LTU'
      binMap = LTUsegmentMap(winMap(idx),winPos{idx});
    otherwise
      error(['Unknown segmentComputeType: ' params.segmentComputeType]);
  end
    
  % check that we actually segmented something, but not too big (< 10%)
  areaRatio = sum(binMap.data(:)) / prod(size(binMap.data));
  if ((areaRatio > 0) & (areaRatio < 0.1))
    
    % this guy looks good - let's keep him!
    shapeData.winningMap = winMap(idx);
    shapeData.winner = winPos{idx};

    % for the IOR mask, we don't want to smooth the shape
    shapeData.iorMask = binMap;
    shapeData.iorMask.data = imdilate(shapeData.iorMask.data,strel('disk',2));
    shapeData.iorMask.label = 'IOR mask';
    
    % for the binary map, erode the shape a bit
    binMap.label = 'binary shape map';
    se = [[0 0 1 0 0];[0 1 1 1 0];[1 1 1 1 1];[0 1 1 1 0];[0 0 1 0 0]];
    tmp = imclose(imopen(binMap.data,se),se);
    newMap = [];
    if (tmp(winPos{idx}(1),winPos{idx}(2)) > 0)
      if (sum(tmp(:)) > 0)
        newMap = tmp;
      end
    else
      se = [[0 1 0];[1 1 1];[0 1 0]];
      tmp = imclose(imopen(binMap.data,se),se);
      if ((tmp(winPos{idx}(1),winPos{idx}(2)) > 0) && (sum(tmp(:)) > 0))
        newMap = tmp;
      end
    end
    if ~isempty(newMap)
      lab = bwlabel(newMap,4);
      binMap.data = double(lab == lab(winPos{idx}(1),winPos{idx}(2)));
    end
    shapeData.binaryMap = binMap;
    gotMap = 1;
    break;
  end
end

% huh - no success in segmentation? Just return empty then
if (~gotMap)
  shapeData = [];
  return;
end

% Hurray, we have a nicely segmented map - let's compute a few more things

% The segmented map is just winning map * binary map
shapeData.segmentedMap.origImage = shapeData.winningMap.origImage;
shapeData.segmentedMap.label = 'segmented shape map';
shapeData.segmentedMap.data = shapeData.winningMap.data .* shapeData.binaryMap.data;
shapeData.segmentedMap.date = clock;
shapeData.segmentedMap.parameters = shapeData.winningMap.parameters;

% The shape map is a smoothed version of the binary map
shapeData.shapeMap.origImage = shapeData.winningMap.origImage;
shapeData.shapeMap.label = [shapeData.binaryMap.label ' - rescaled'];
tmp = imresize(shapeData.binaryMap.data,...
               shapeData.shapeMap.origImage.size(1:2),'nearest');
kernel = gaussian(0,15,15);
tmp = normalizeImage(sepConv2PreserveEnergy(kernel,kernel,tmp),[0,3]);
shapeData.shapeMap.data = clamp(tmp,0,1);

shapeData.shapeMap.date = clock;
shapeData.shapeMap.parameters = shapeData.winningMap.parameters;

shapeData.date = clock;
