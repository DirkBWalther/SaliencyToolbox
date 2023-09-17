% evolveWTA - evolves the winner-take-all network by one time step.
%
% [wta,winner] = evolveWTA(wta)
%    Evolves wta by one time step, returns the resulting wta,
%    and returns the winner coordinates if a winner was found.
%
% See also evolveLeakyIntFire, runSaliency, dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function [wta,winner] = evolveWTA(wta)

time = wta.exc.time + wta.exc.timeStep;
winner = [-1,-1];

% first evolve the sm
wta.sm = evolveLeakyIntFire(wta.sm,time);

% set the input into the excitatory WTA neurons to the output of the sm
wta.exc.I = wta.sm.V .* wta.exc.Ginput;

% evolve the excitatory neurons of the WTA network
[wta.exc,spikes] = evolveLeakyIntFire(wta.exc,time);

% erase any inhibitions we might have had
wta.exc.Ginh = 0;

% did anyone fire?
if any(spikes(:))
  idx = find(spikes); idx = idx(1);
  [winner(1),winner(2)] = ind2sub(size(spikes),idx);
    
  debugMsg(sprintf('winner: (%d,%d) at %f ms',winner(1),winner(2),time*1000));
  debugMsg(sprintf('SM voltage at winner: %g mV above rest',wta.sm.V(idx)*1000));

  % the inihibitory interneuron gets all excited about the winner
  wta.inhib.Gexc = wta.inhib.Gleak * 10;
end
  
% evolve the inhibitory interneuron
[wta.inhib,spike] = evolveLeakyIntFire(wta.inhib,time);
if (spike)
  % trigger global inhibition
  wta.exc.Ginh = 1e-2;
  
  % no need to be excited anymore
  wta.inhib.Gexc = 0;
end
