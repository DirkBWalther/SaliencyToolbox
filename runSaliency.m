% runSaliency - compute and display saliency map and fixations.
%
% runSaliency(inputImage,saliencyParams)
%    Runs a demonstration of the entire process of computing
%    the saliency map, winner-take-all evolution with 
%    inhibition of return, shape estimation, and fixation
%    to the attended region.
%       inputImage: the file name of the image,
%                   or the image data themselves,
%                   or an initialized Image structure (see initializeImage);
%       saliencyParams: the saliency parameter set for the operations.
%
% runSaliency(inputImage)
%    Uses defaultSaliencyParams as parameters.
%
% See also guiSaliency, batchSaliency, initializeGlobal, initializeImage, 
%          makeSaliencyMap, initializeWTA, evolveWTA, applyIOR, estimateShape, 
%          dataStructures, defaultSaliencyParams. 

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function runSaliency(inputImage,varargin)

declareGlobal;

% initialize the Image structure if necessary
if (isa(inputImage,'struct'))
  img = inputImage;
else
  img = initializeImage(inputImage);
end

% check that image isn't too huge
img = checkImageSize(img,'Prompt');

% use the default saliency parameters if the user didn't specify any
if isempty(varargin)
  params = defaultSaliencyParams(img.size,'dyadic');
else
  params = varargin{1};
end

% make sure that we don't use color features if we don't have a color image
if (img.dims == 2)
  params = removeColorFeatures(params);
end

% create the saliency map
[salmap,salData] = makeSaliencyMap(img,params);

% display the conspicuity maps
figure('Name','STB: conspicuity maps','NumberTitle','off'); 
displayMaps({salData.CM},2);

% initialize the winner-take-all network
wta = initializeWTA(salmap,params);

% display the input image
imgFig = showImage(img);

% display the current WTA
salFig = figure('Name','STB: Saliency Map and WTA','NumberTitle','off');
wtaMap = emptyMap(img.size(1:2),'Winner Take All');
wtaMap.data = imresize(wta.sm.V,img.size(1:2),'bilinear');
displayMaps([salmap,wtaMap],1);

shapeFig = -1;
lastWinner = [-1,-1];
reply = '';

% loop over the successive fixations, until user enters 'q' or 'Q'
while (~strcmp(reply,'q') & ~strcmp(reply,'Q'))
  winner = [-1,-1];

  % evolve WTA until we have a winner
  while (winner(1) == -1)
    [wta,winner] = evolveWTA(wta);
  end

  % update the WTA plot
  figure(salFig);
  wtaMap = emptyMap(img.size(1:2),'Winner Take All');
  wtaMap.data = imresize(wta.sm.V,img.size(1:2),'bilinear');
  displayMaps([salmap,wtaMap],1);
  
  % run the shape estimator to get proro-objects
  shapeData = estimateShape(salmap,salData,winner,params);

  % trigger inhibition of return
  wta = applyIOR(wta,winner,params,shapeData);
    
  % convert the winner's location to image coordinates
  win2 = winnerToImgCoords(winner,params);
 
  % plot the currently attended region into the image figure
  figure(imgFig);
  plotSalientLocation(win2,lastWinner,img,params,shapeData);
  
  lastWinner = win2;
  
  % in case we have shape data, create a plot 
  % to display various processing steps
  if ~isempty(shapeData)
    
    % need to open a new figure or use the previous one?
    if (shapeFig == -1) 
      shapeFig = figure('Name','STB: shape maps','NumberTitle','off'); 
    else
      figure(shapeFig);
    end
    
    % draw the various maps
    displayMaps({shapeData.winningMap,shapeData.segmentedMap,...
                 shapeData.binaryMap,shapeData.shapeMap});
    
    % find the right label for the figure window
    winLabel = [' - ' shapeData.winningMap.label];
    if any(isnan(img.filename))
      lab = winLabel;
    else
      lab = [img.filename winLabel];
    end
    set(imgFig,'Name',lab);
  else
    winLabel = '';
  end
  
  % make sure everything gets drawn
  drawnow;
  
  % write out the details for our winner
  txt = sprintf('winner: %i,%i; t = %4.1f ms%s',...
                win2(2),win2(1),wta.exc.time*1000,winLabel);
  
  % wait for user input - return for next fixation, 'q' to terminate
  reply = input(txt,'s');
end
