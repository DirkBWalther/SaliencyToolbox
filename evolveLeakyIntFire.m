% evolveLeakyIntFire - evolves an LIF network by one time step.
%
% [LIF,spikes] = evolveLeakyIntFire(LIF,t)
%    Computes on integration step of length t for the network 
%    of leaky integrate and fire neurons in LIF, return the 
%    new LIF neurons, and return a vector of spiking activity 
%    (0 or 1) in spikes.
%
% See also defaultLeakyIntFire, evolveWTA, dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function [LIF,spikes] = evolveLeakyIntFire(LIF,t)

dt = t - LIF.time;

% integrate
LIF.V = LIF.V + dt./LIF.C * (LIF.I - LIF.Gleak.*(LIF.V - LIF.Eleak) - ...
                             LIF.Gexc.*(LIF.V - LIF.Eexc) - ...
                             LIF.Ginh.*(LIF.V - LIF.Einh));
  
% clamp potentials that are lower than Einh
idx = (LIF.V < LIF.Einh);
if (length(LIF.Einh) > 1)
  LIF.V(idx) = LIF.Einh(idx);
else
  LIF.V(idx) = LIF.Einh;
end

% let Ginh decay (for IOR to wear off)
LIF.Ginh = LIF.Ginh * LIF.GinhDecay;
  
% fire?
spikes = (LIF.V > LIF.Vthresh) & LIF.DoesFire;

% reset units that have just fired
LIF.V(spikes) = 0;
  
LIF.time = t;
