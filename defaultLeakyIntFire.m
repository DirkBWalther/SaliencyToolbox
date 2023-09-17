% defaultLeakyIntFire - creates a default LIF neuron.
%
% LIF = defaultLeakyIntFire
%    Creates an integrate and fire neuron data structure with
%    default values.
%
% See also initializeWTA, evolveLeakyIntFire, dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

% all in SI units!!!

function LIF = defaultLeakyIntFire

LIF.timeStep = 0.0001; % seconds
LIF.Eleak = 0;         % Volts
LIF.Eexc = 100e-3;     % Volts
LIF.Einh = -20e-3;     % Volts
LIF.Gleak = 1e-8;      % Siemens
LIF.Gexc = 0;          % Siemens
LIF.Ginh = 0;          % Siemens
LIF.GinhDecay = 1;     % Siemens
LIF.Ginput = 5e-8;     % Siemens
LIF.Vthresh = 0.001;   % Volts
LIF.C = 1e-9;          % Farad
LIF.time = 0;          % seconds
LIF.V = 0;             % Volts
LIF.I = 0;             % Ampere
LIF.DoesFire = 1;      % binary
