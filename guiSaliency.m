% guiSaliency - a graphical user interface (GUI) version of the saliency code.
%
% guiSaliency
%    Starts the GUI and lets you select an image via the controls.
%
% guiSaliency(inputImage)
%    Uses inputImage as the image.
%       inputImage: the filename of the image,
%                   or the image data themselves,
%                   or an initialized Image structure (see initializeImage).
%
% guiSaliency(...,saliencyParams)
%    Uses the parameters specified in saliencyParams instead of the default
%    parameters.
%
% See also runSaliency, batchSaliency, initializeImage, defaultSaliencyParams,
%          guiLevelParams, dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function varargout = guiSaliency(varargin)
% GUI initialization code
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guiSaliency_OpeningFcn, ...
                   'gui_OutputFcn',  @guiSaliency_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);

stack = dbstack;
if nargin && ischar(varargin{1}) && ismember([mfilename '.m'],{stack(1:end-1).file})
  gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% opening code executes just before guiSaliency is made visible.
function guiSaliency_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
guidata(hObject, handles);

% set the close callback for the main window
set(hObject,'CloseRequestFcn',@MainWindowCloseCallback);

% define the needed global variables
declareGlobal;
global globalVars;
globalVars = 'global img params state salMap salData wta lastWinner winner shapeData';
eval(globalVars);
state = 'NoImage';

% try to use user-given image
if (length(varargin) >= 1)
  switch class(varargin{1})
    case 'struct'
      newImg = varargin{1};
      err = '';
      state = 'ImageLoaded';
    case {'char','uint8','double'}
      [newImg,err] = initializeImage(varargin{1});
    otherwise
      err = 1;
  end
  if isempty(err)
    img = checkImageSize(newImg,'GUI');
    if isnan(img.filename)
      imgName = '(from input arguments)';
    else
      imgName = img.filename;
    end
    set(handles.ImageName,'String',imgName);
    state = 'ImageLoaded';
  else
    beep;
    if ischar(varargin{1})
      name = varargin{1};
    else
      name = 'This';
    end
    uiwait(warndlg([name ' is not a valid image!'],...
                   'Not a valid image','modal'));
  end
end

% use user-given parameters if given
if (length(varargin) >= 2)
  if isstruct(varargin{2})
    params = varargin{2};
  else
    params = defaultSaliencyParams(img.size);
  end
else
  if isempty(img);
    params = defaultSaliencyParams;
  else
    params = defaultSaliencyParams(img.size);
  end
end

% some more initializations
setState(handles);
checkColorParams(handles);
fillParams(handles);
initializeVisFigures(handles);
updateImg(handles);
updateLocImg(handles);
debugMsg(sprintf('%s initialized in state: %s.',mfilename,state));

% this waits until the "Quit" button is pressed
uiwait(handles.figure1);

% clean up
cleanupVisFigures(handles);
eval(['clear ' globalVars 'globalVars']);
debugMsg('Global variables cleared - bye.');

try
  delete(handles.figure1);
catch
  % nothing to do
end
% that's it, bye bye.
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs from this function are returned to the command line.
function varargout = guiSaliency_OutputFcn(hObject, eventdata, handles)
varargout{1} = hObject;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update the GUI according to the current state
function setState(h,newState)
global state;
if (nargin >= 2)
  state = newState;
end

debugMsg(['Setting state: ' state]);
switch state
  case 'NoImage'
    set(h.figure1,'Pointer','arrow');
    setEnable(0,[h.Restart,h.NextLoc,h.SaveMaps]);
    set(h.NextLoc,'String','Start');
  case 'ImageLoaded'
    set(h.figure1,'Pointer','arrow');
    setEnable(0,[h.Restart,h.SaveMaps]);
    setEnable(1,h.NextLoc);
    set(h.NextLoc,'String','Start');
  case 'MapsComputed'
    set(h.figure1,'Pointer','arrow');
    setEnable(1,[h.Restart,h.NextLoc,h.SaveMaps]);
    set(h.NextLoc,'String','Next Location');
  case 'Busy'
    set(h.figure1,'Pointer','watch');
    setEnable(0,[h.Restart,h.NextLoc,h.SaveMaps]);
  otherwise
    debugMsg(['Unknown state:' state]);
end
drawnow;
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set color features according to image type
function checkColorParams(handles)
global params img;
if ~isempty(img)
  switch img.dims
    case 2
      % gray-scale image: no color features
      params = removeColorFeatures(params,0);
      setEnable(0,[handles.Color,handles.WeightCol,...
                   handles.Skin,handles.WeightSkin]);
      debugMsg('Gray scale image - removed color features.');
    case 3
      % color image
      setEnable(1,[handles.Color,handles.Skin]);
      setFeature(handles.Color,handles.WeightCol);
      setFeature(handles.Skin,handles.WeightSkin);
    otherwise
      debugMsg(sprintf('Unknown image format with %d dimensions.',img.dims));
  end
end
return;

               
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fill the GUI with the parameters from the global variable params
function fillParams(handles)
global params DEBUG_FID;
setFeature(handles.Color,handles.WeightCol);
setFeature(handles.Intensities,handles.WeightInt);
setFeature(handles.Orientations,handles.WeightOri);
setFeature(handles.Skin,handles.WeightSkin);
setEnable(get(handles.Orientations,'Value'),[handles.NumOriText,handles.NumOri]);
set(handles.NumOri,'String',num2str(numel(params.oriAngles)));
setNormType(handles);
setShapeMode(handles);
set(handles.ToggleDebug,'Value',DEBUG_FID);

styleStrings = {'Contour','ContrastModulate','None'};
style = strmatch(params.visualizationStyle,styleStrings);
if isempty(style)
  style = 3;
end
set(handles.VisStyle,'Value',style,'UserData',styleStrings);

return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check with user that parameters can be changed
function response = confirmParamsChange(handles)
global state;
switch state
  case {'NoImage','ImageLoaded'}
    response = 1;
  case 'MapsComputed'
    button = questdlg({'Changing the parameters now will reset the computation.',...
                       'Would you like to proceed anyway?'},...
                       'Change parameters?',...
                       'Yes','No','Yes');
    response = strcmp(button,'Yes');
    if response
      setState(handles,'ImageLoaded');
      fprintf('---------------------------\n');
    end
  otherwise
    debugMsg(['Unknown state: ' state]);
    response = 0;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loading an image
function NewImage_Callback(hObject, eventdata, handles)
declareGlobal;
global img params state;
prevState = state;
setState(handles,'Busy');

if isempty(img)
  defName = '';
else
  defName = img.filename;
end

err = 1;
while ~isempty(err)
  [newName,newPath] = uigetfile('*.*','Select an new image',defName);
  if (newName == 0)
    % User pressed 'cancel' - keep old file
    setState(handles,prevState);
    return;
  end
  
  [newImg,err] = initializeImage([newPath newName]);
  if ~isempty(err)
    beep;
    uiwait(warndlg(sprintf('%s is not a valid image!',newName),...
                   'Not a valid image','modal'));
    defName = '';
  end
end

% image is okay, set as img for analyses
img = checkImageSize(newImg,'GUI');
set(handles.ImageName,'String',newName);
if (params.foaSize < 0)
  p = defaultSaliencyParams(img.size);
  params.foaSize = p.foaSize;
  setShapeMode(handles);
end

% Replacing an old image? output separator
if strcmp(prevState,'MapsComputed')
  fprintf('---------------------------\n');
end

% some house keeping
state = 'ImageLoaded';
checkColorParams(handles);
updateImg(handles);
updateLocImg(handles);
setState(handles);
debugMsg(sprintf('Loaded image %s.\n',img.filename));
return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Feature selection and weights                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the values for a particular feature from the GUI controls
function getFeature(hSelect,hWeight,handles)
global params;
if ~confirmParamsChange(handles)
  return;
end
name = get(hSelect,'Tag');
idx = strmatch(name,params.features);

if get(hSelect,'Value')
  set(hWeight,'Enable','on');

  % need to add this feature?
  if isempty(idx)
    params.features = {params.features{:},name};
    params.weights = [params.weights 1];
    idx = strmatch(name,params.features);
  end
  
  % get weight value from text box
  w = str2num(get(hWeight,'String'));
  if ~isempty(w)
    params.weights(idx(1)) = w(1);
  end
else
  set(hWeight,'Enable','off');
  
  % need to remove this feature?
  if ~isempty(idx)
    newIdx = setdiff([1:length(params.features)],idx);
    params.features = {params.features{newIdx}};
    parmas.weights = [params.weights(newIdx)];
  end
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set the GUI controls for a particular feature
function setFeature(hSelect,hWeight)
global params;
name = get(hSelect,'Tag');
idx = strmatch(name,params.features);

if isempty(idx)
  set(hSelect,'Value',0);
  set(hWeight,'Enable','off');
else
  set(hSelect,'Value',1);
  set(hWeight,'Enable','on','String',num2str(params.weights(idx(1))));
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% enable/disable a vector of GUI elements
function setEnable(value,hs)
enableStrings = {'off','on'};
for h = 1:length(hs)
  set(hs(h),'Enable',enableStrings{value+1});
end
return;


%%%% Color %%%%

% Color checkbox
function Color_Callback(hObject, eventdata, handles)
getFeature(handles.Color,handles.WeightCol,handles);
setFeature(handles.Color,handles.WeightCol);

% Color weight textbox
function WeightCol_Callback(hObject, eventdata, handles)
getFeature(handles.Color,handles.WeightCol,handles);
setFeature(handles.Color,handles.WeightCol);

% Create color weight textbox
function WeightCol_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%% Intensities %%%%

% Intensities checkbox
function Intensities_Callback(hObject, eventdata, handles)
getFeature(handles.Intensities,handles.WeightInt,handles);
setFeature(handles.Intensities,handles.WeightInt);

% Intensities weight textbox
function WeightInt_Callback(hObject, eventdata, handles)
getFeature(handles.Intensities,handles.WeightInt,handles);
setFeature(handles.Intensities,handles.WeightInt);

% create Intensities weight textbox
function WeightInt_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%% Orientations %%%%

% Orientations checkbox
function Orientations_Callback(hObject, eventdata, handles)
getFeature(handles.Orientations,handles.WeightOri,handles);
setFeature(handles.Orientations,handles.WeightOri);
setEnable(get(hObject,'Value'),[handles.NumOriText,handles.NumOri]);

% Orientaions weight textbox
function WeightOri_Callback(hObject, eventdata, handles)
getFeature(handles.Orientations,handles.WeightOri,handles);
setFeature(handles.Orientations,handles.WeightOri);

% create Orientations weight textbox
function WeightOri_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% number of orientations textbox
function NumOri_Callback(hObject, eventdata, handles)
global params
if confirmParamsChange(handles)
  n = str2num(get(hObject,'String'));
  if ~isempty(n)
    n = max(round(n(1)),1);
    params.oriAngles = [0:(n-1)] * 180 / n;
  end
end
set(hObject,'String',num2str(numel(params.oriAngles)));

% create number of orientations textbox
function NumOri_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%% Skin hue %%%%

% skin hue checkbox
function Skin_Callback(hObject, eventdata, handles)
getFeature(handles.Skin,handles.WeightSkin,handles);
setFeature(handles.Skin,handles.WeightSkin);

% skin hue weight textbox
function WeightSkin_Callback(hObject, eventdata, handles)
getFeature(handles.Skin,handles.WeightSkin,handles);
setFeature(handles.Skin,handles.WeightSkin);

% create skin hue weight textbox
function WeightSkin_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Parameters                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SetPyrLevels button
function SetPyrLevels_Callback(hObject, eventdata, handles)
global params
if confirmParamsChange(handles)
  params.levelParams = guiLevelParams(params.levelParams);
end

% set the GUI normtype controls to parameters
function setNormType(handles)
global params;
normTypes = get(handles.NormType,'String');
idx = strmatch(params.normtype,normTypes);
if isempty(idx)
  params.normtype = normTypes{get(handles.NormType,'Value')};
else
  set(handles.NormType,'Value',idx(1));
end
isIter = strcmp(params.normtype,'Iterative');
setEnable(isIter,[handles.NumIterText,handles.NumIter])
set(handles.NumIter,'String',num2str(params.numIter));

% get the normtype parameters from the GUI controls
function getNormType(handles)
global params;
if ~confirmParamsChange(handles)
  return;
end
normTypes = get(handles.NormType,'String');
params.normtype = normTypes{get(handles.NormType,'Value')};
niter = str2num(get(handles.NumIter,'String'));
if ~isempty(niter)
  niter = round(niter(1));
  if (niter < 0)
    niter = 0;
  end
  params.numIter = niter;
end

% NormType drop-down list
function NormType_Callback(hObject, eventdata, handles)
getNormType(handles);
setNormType(handles);

% create NormType drop-down list
function NormType_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% NumIter textbox
function NumIter_Callback(hObject, eventdata, handles)
getNormType(handles);
setNormType(handles);

% create NumIter textbox
function NumIter_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setting shape mode                                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get the shape mode parameters form the GUI controls
function getShapeMode(handles)
global params;
if ~confirmParamsChange(handles)
  return;
end
shapeModes = {'None','shapeSM','shapeCM','shapeFM','shapePyr'};
params.shapeMode = shapeModes{get(handles.ShapeMode,'Value')};

newFS = str2num(get(handles.FOAsize,'String'));
if ~isempty(newFS)
  if (newFS < 0)
    newFS = 0;
  end
  params.foaSize = newFS;
end
return;

% set the shape mode GUI controls according to the parameters
function setShapeMode(handles)
global params;
shapeModes = {'None','shapeSM','shapeCM','shapeFM','shapePyr'};
mode = strmatch(params.shapeMode,shapeModes);
if ~isempty(mode)
  set(handles.ShapeMode,'Value',mode(1));
end

isNone = strcmp(params.shapeMode,shapeModes{1});
setEnable(isNone,[handles.FOAsize,handles.FOAsizeText]);
if (params.foaSize >= 0)
  set(handles.FOAsize,'String',num2str(params.foaSize));
else
  set(handles.FOAsize,'String','');
end
return;

% ShapeMode drop-down list
function ShapeMode_Callback(hObject, eventdata, handles)
getShapeMode(handles);
setShapeMode(handles);

% create ShapeMode drop-down list
function ShapeMode_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% FOAsize textbox
function FOAsize_Callback(hObject, eventdata, handles)
getShapeMode(handles);
setShapeMode(handles);


% create FOAsize textbox
function FOAsize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setting visualizations                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initializes plot windows
function initializeVisFigures(handles)
visHandles = [handles.VisImg,handles.VisSM,handles.VisCM,...
              handles.VisShape,handles.VisLoc];
for h = visHandles
  visStrings = {'off','on'};
  figH = figure;
  vis = get(h,'Value')+1;
  set(figH,'Name',['STB: ' get(h,'String')],...
           'NumberTitle','off',...
           'CloseRequestFcn',@VisFigureCloseCallback,...
           'UserData',h,...
           'Visible',visStrings{vis});
  set(h,'UserData',figH);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% delete the visualization figures, e.g. when the 'Quit' button is pressed
function cleanupVisFigures(handles)
visHandles = [handles.VisImg,handles.VisSM,handles.VisCM,...
              handles.VisShape,handles.VisLoc];
for h = visHandles
  figH = get(h,'UserData');
  delete(figH);
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% callback function for closing figures - just make them invisible
function VisFigureCloseCallback(hSrc,event)
hObject = get(hSrc,'UserData');
set(hObject,'Value',0);
set(hSrc,'Visible','off');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set the GUI controls and figure visibility
function setVisFigure(hObject,handles)
enableStrings = {'off','on'};
figH = get(hObject,'UserData');
val = get(hObject,'Value')+1;
try
  set(figH,'Visible',enableStrings{val});
catch
  figH = figure;
  set(figH,'Visible',enableStrings{val});
  set(hObject,'UserData',figH);
end


% do the above for all visualization figures
function setAllVisFigures(handles)
visHandles = [handles.VisImg,handles.VisSM,handles.VisCM,...
              handles.VisShape,handles.VisLoc];
for h = visHandles
  setVisFigure(h,handles);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update the 'image' visualization figure
function updateImg(handles)
global state img;
figH = get(handles.VisImg,'UserData');
if strcmp(get(figH,'Visible'),'on')
  switch state
    case {'ImageLoaded','MapsComputed'}
      figure(figH);
      displayImage(img);
      figure(handles.figure1);
    otherwise
      % do nothing
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update the 'saliency map' visualization figure
function updateSM(handles)
global state salMap wta img;
figH = get(handles.VisSM,'UserData');
if strcmp(get(figH,'Visible'),'on')
  switch state
    case 'MapsComputed'
      figure(figH);
      wtaMap = emptyMap(img.size(1:2),'Winner Take All');
      wtaMap.data = imresize(wta.sm.V,img.size(1:2),'bilinear');
      displayMaps([salMap,wtaMap],1);
      figure(handles.figure1);
    otherwise
      % do nothing
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update the 'conspicuity maps' visualization figure
function updateCM(handles)
global state salData;
figH = get(handles.VisCM,'UserData');
if strcmp(get(figH,'Visible'),'on')
  switch state
    case 'MapsComputed'
      figure(figH);
      displayMaps([salData(:).CM],1);
      figure(handles.figure1);
    otherwise
      % do nothing
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update the 'shape maps' visualization figure
function winLabel = updateShape(handles)
global state shapeData;
if isempty(shapeData)
  winLabel = '';
else
  winLabel = [' - ' shapeData.winningMap.label];
  figH = get(handles.VisShape,'UserData');
  if strcmp(get(figH,'Visible'),'on')
    switch state
      case 'MapsComputed'
        figure(figH);
        displayMaps({shapeData.winningMap,shapeData.segmentedMap,...
                     shapeData.binaryMap,shapeData.shapeMap});
        figure(handles.figure1);
      otherwise
        % do nothing
    end
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update the 'attended location' visualization figure
function updateLoc(handles)
global globalVars;
eval(globalVars);
figH = get(handles.VisLoc,'UserData');
if strcmp(get(figH,'Visible'),'on')
  switch state
    case 'ImageLoaded'
      updateLocImg(handles);
    case 'MapsComputed'
      figure(figH);
      plotSalientLocation(winner,lastWinner,img,params,shapeData);
      if ~isempty(shapeData)
        title(['shape from: ' shapeData.winningMap.label]);
      end
      figure(handles.figure1);
    otherwise
      % do nothing
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update the image in the 'attended location' visualization figure
function updateLocImg(handles)
global state img params;
figH = get(handles.VisLoc,'UserData');
if strcmp(get(figH,'Visible'),'on')
  switch state
    case {'ImageLoaded','MapsComputed'}
      figure(figH);
      displayImage(img);
      setVisFigure(handles.VisLoc,handles);
      figure(handles.figure1);
    otherwise
      % do nothing
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI controls for the visualization figures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% visualize image checkbox
function VisImg_Callback(hObject, eventdata, handles)
setVisFigure(hObject,handles);
updateImg(handles);

% visualize SM checkbox
function VisSM_Callback(hObject, eventdata, handles)
setVisFigure(hObject,handles);
updateSM(handles);

% visualize CM checkbox
function VisCM_Callback(hObject, eventdata, handles)
setVisFigure(hObject,handles);
updateCM(handles);

% visualize Shape checkbox
function VisShape_Callback(hObject, eventdata, handles)
setVisFigure(hObject,handles);
updateShape(handles);

% visualize location checkbox
function VisLoc_Callback(hObject, eventdata, handles)
global lastWinner;
lastWinner = [-1,-1];
setVisFigure(hObject,handles);
updateLoc(handles);

% visualization style drop-down list
function VisStyle_Callback(hObject, eventdata, handles)
global globalVars;
eval(globalVars);
styleStrings = get(hObject,'UserData');
val = get(hObject,'Value');
params.visualizationStyle = styleStrings{val};
lastWinner = [-1,-1];
set(handles.VisLoc,'Value',1);
setVisFigure(handles.VisLoc,handles);
updateLocImg(handles);
updateLoc(handles);

function VisStyle_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parameters management
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% reset parameters to the default
function DefaultSettings_Callback(hObject, eventdata, handles)
global params img;
if confirmParamsChange(handles)
  if isempty(img)
    params = defaultSaliencyParams;
  else
    params = defaultSaliencyParams(img.size);
  end
  checkColorParams(handles);
  fillParams(handles);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save parameters
function SaveSettings_Callback(hObject, eventdata, handles)
global params;
debugMsg('Saving settings.');
[filename,path] = uiputfile('*.mat','Save parameters as ...',...
                            'parameters.mat');
if (filename ~= 0)
  save([path filename],'params');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load parameters
function LoadSettings_Callback(hObject, eventdata, handles)
global params;
if confirmParamsChange(handles)
  debugMsg('Loading settings.');
  [filename,path] = uigetfile('*.mat','Loading parameters from ...',...
                              'parameters.mat');
  if (filename ~= 0)
    try
      in = load([path filename]);
    catch
      uiwait(warndlg([filename ' is not a data file!'],...
             'Not a valid data file','modal'));
      return;
    end
    fnames = fieldnames(in);
    if strmatch('params',fnames)
      % we have a params field - great, let's take it
      params = in.params;
      fillParams(handles);
    elseif (length(fnames) == 1)
      % just one field - let's use this one
      params = getfield(in,fnames{1});
      fillParams(handles);
    else
      % couldn't find params in this file
      uiwait(warndlg(['Could not find params in ' filename],...
             'Params not found','modal'));
    end
    checkColorParams(handles);
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save maps
function SaveMaps_Callback(hObject, eventdata, handles)
global salMap wta salData shapeData;
debugMsg('Saving maps.');
[filename,path] = uiputfile('*.mat','Save maps in ...',...
                            'maps.mat');
if (filename ~= 0)
  save([path filename],'salMap','wta','salData','shapeData');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Switch Debugging messages on/off
function ToggleDebug_Callback(hObject, eventdata, handles)
global DEBUG_FID
DEBUG_FID = get(hObject,'Value');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reset button
function Restart_Callback(hObject, eventdata, handles)
setState(handles,'ImageLoaded');
fprintf('---------------------------\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% saliency computation functions and controls
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start / Next Location button
function NextLoc_Callback(hObject, eventdata, handles)
global globalVars;
eval(globalVars);
switch state
  case 'ImageLoaded'
    debugMsg('Computing new maps ...');
    setState(handles,'Busy');
    [salMap,salData] = makeSaliencyMap(img,params);
    wta = initializeWTA(salMap,params);
    state = 'MapsComputed';
    winner = [-1,-1];
    updateCM(handles);
    updateLocImg(handles);
    NextLoc_Callback(hObject, eventdata, handles);
  case 'MapsComputed'
    debugMsg('Going to the next location ...');
    setState(handles,'Busy');
    lastWinner = winner;
    thisWinner = [-1,-1];
    while (thisWinner(1) == -1)
      [wta,thisWinner] = evolveWTA(wta);
    end
    shapeData = estimateShape(salMap,salData,thisWinner,params);
    wta = applyIOR(wta,thisWinner,params,shapeData);
    winner = winnerToImgCoords(thisWinner,params);
    state = 'MapsComputed';
    updateSM(handles);
    winLabel = updateShape(handles);
    updateLoc(handles);
    fprintf('winner: %i,%i; t = %4.1f ms%s\n',...
            winner(2),winner(1),wta.exc.time*1000,winLabel);
  otherwise
    debugMsg(['Unexpected state: ' state]);
end
setState(handles);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% About button
function About_Callback(hObject, eventdata, handles)
uiwait(msgbox({...
  'SaliencyToolbox 2.2',...
  'http://www.saliencytoolbox.net','',...
  'Copyright 2006-2008 by Dirk B. Walther and',... 
  'the California Institutute of Technology','',...
  'Type ''STBlicense'' to view the license agreement.',''},...
  'About SaliencyToolbox','modal'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Quit button
function Quit_Callback(hObject, eventdata, handles)
setState(handles,'Busy');
uiresume(handles.figure1);

% Close button on the main window
function MainWindowCloseCallback(hObject,event)
handles = guidata(hObject);
setState(handles,'Busy');
uiresume(hObject);

