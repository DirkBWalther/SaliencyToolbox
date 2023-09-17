% guiLevelParams - a graphical user interface (GUI) to adjust parameter level parameters.
%
% newLevelParams = guiLevelParams(oldLevelParams)
%    Lets the user adjust the old parameters and returns them as new parameters.
%    If oldLevelParams are ommitted, defaultLevelParams are used.
%
% See also defaultLevelParams, guiSaliency, defaultSaliencyParams,
%          centerSurround, winnerToImgCoords, dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function varargout = guiLevelParams(varargin)

% GUI initialization code
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guiLevelParams_OpeningFcn, ...
                   'gui_OutputFcn',  @guiLevelParams_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% opening code executes just before guiLevelParams is made visible.
function guiLevelParams_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
guidata(hObject, handles);

% get the old parameters from the command line or use default?
global lparams;
if isempty(varargin)
  lparams = defaultLevelParams('dyadic');
else
  lparams = varargin{1};
end

fillParams(handles);

% this waits for the user to press 'cancel' or 'ok'
set(handles.figure1,'WindowStyle','modal')
uiwait(handles.figure1);

% clean up
try
  delete(handles.figure1);
catch
  % nothing to do
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fill the GUI with the parameters from the global variable params
function fillParams(handles)
global lparams;
set(handles.minLevel,'String',num2str(lparams.minLevel));
set(handles.minLevel,'UserData',lparams.minLevel);
set(handles.maxLevel,'String',num2str(lparams.maxLevel));
set(handles.maxLevel,'UserData',lparams.maxLevel);
set(handles.minDelta,'String',num2str(lparams.minDelta));
set(handles.minDelta,'UserData',lparams.minDelta);
set(handles.maxDelta,'String',num2str(lparams.maxDelta));
set(handles.maxDelta,'UserData',lparams.maxDelta);
set(handles.mapLevel,'String',num2str(lparams.mapLevel));
set(handles.mapLevel,'UserData',lparams.mapLevel);
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set command line output to the new parameters and clean up
function varargout = guiLevelParams_OutputFcn(hObject, eventdata, handles) 
global lparams;
varargout{1} = lparams;
clear global lparams;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make sure that the text field hObject contains a valid integer >1,
% store the valid value in the text field's UserData
function checkNumber(hObject)
num = str2num(get(hObject,'String'));
if ~isempty(num)
  num = round(num(1));
  if (num < 1) num = 1; end
  set(hObject,'UserData',num);
end
set(hObject,'String',num2str(get(hObject,'UserData')));
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the text fields with the values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% minLevel
function minLevel_Callback(hObject, eventdata, handles)
checkNumber(hObject);

function minLevel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% maxLevel
function maxLevel_Callback(hObject, eventdata, handles)
checkNumber(hObject);

function maxLevel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% minDelta
function minDelta_Callback(hObject, eventdata, handles)
checkNumber(hObject);

function minDelta_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% maxDelta
function maxDelta_Callback(hObject, eventdata, handles)
checkNumber(hObject);

function maxDelta_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% mapLevel
function mapLevel_Callback(hObject, eventdata, handles)
checkNumber(hObject);

function mapLevel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% buttons
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Defaults button
function defaults_Callback(hObject, eventdata, handles)
global lparams;
lparams = defaultLevelParams('dyadic');
fillParams(handles);

% Cancel button
function cancel_Callback(hObject, eventdata, handles)
uiresume(handles.figure1);

% OK button
function ok_Callback(hObject, eventdata, handles)
global params lparams;

% read the new parameters from the text fields
lparams.minLevel = get(handles.minLevel,'UserData');
lparams.maxLevel = get(handles.maxLevel,'UserData');
lparams.minDelta = get(handles.minDelta,'UserData');
lparams.maxDelta = get(handles.maxDelta,'UserData');
lparams.mapLevel = get(handles.mapLevel,'UserData');

% check that surround levels are okay
if (lparams.minLevel > lparams.maxLevel)
  uiwait(warndlg('''lowest center level'' must be lower than ''highest center level''!',...
                 'Please correct!','modal'));
  return;
end

% check that c-s delta range is valid
if (lparams.minDelta > lparams.maxDelta)
  uiwait(warndlg('''smallest c-s delta'' must be smaller than ''largest c-s delta''!',...
                 'Please correct!','modal'));
  return;
end
uiresume(handles.figure1);
