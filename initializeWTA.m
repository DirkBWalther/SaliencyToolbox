% initializeWTA - intitializes a winner-take-all network.
%
% wta = initializeWTA(saliencyMap,saliencyParams)
%    Initializes a winner-take-all network of leaky 
%    integrate and fire neurons with the current
%    inputs to the neurons set proportional to the
%    values of the saliencyMap.
%
% See also evolveWTA, defaultLeakyIntFire, runSaliency,
%          defaultSaliencyParams, dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function wta = initializeWTA(salmap,salParams)

wta.sm = defaultLeakyIntFire;
wta.sm.C = 5e-8;
wta.sm.Einh = 0;
wta.sm.Eexc = 0;
wta.sm.Gleak = 1e-7;
wta.sm.Ginh = zeros(size(salmap.data));
wta.sm.GinhDecay = salParams.IORdecay;
wta.sm.DoesFire = 0;
wta.sm.I = salmap.data * salParams.smOutputRange + ...
           salParams.noiseAmpl * rand(size(salmap.data)) + ...
           salParams.noiseConst;
debugMsg('salmap input into WTA',wta.sm.I);
wta.sm.V = zeros(size(salmap.data));

wta.exc = defaultLeakyIntFire;
wta.exc.I = zeros(size(salmap.data));
wta.exc.V = zeros(size(salmap.data));
wta.exc.Ginh = 1e-2;

wta.inhib = defaultLeakyIntFire;
