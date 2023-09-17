% LTUsimulate - simulates an LTU network for numIter time steps.
%
% [output,newStates] = LTUsimulate(LTUnetwork,states,inputs,numIter)
%    simlulates an LTUnetwork with states and input for numIter
%    time steps, returns the new states and the output.
%       LTUnetwork contains the information for connectivity and for 
%          which cells in the network are input and output cells;
%       states is a vector containing a state (0 or 1) for each unit;
%       input is the numerical input values into the network;
%       numIter is the number of iterations to be simulated.
%
%       output is a vector of network outputs (0 or 1);
%       newStates is the new state vector for the network.
%
% See also makeLTUsegmentNetwork, LTUsegmentMap, dataStructures.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function [output,newStates] = LTUsimulate(LTUnetwork,states,inputs,numIter)

% do the simulation cycles
for iter = 1:numIter

  % set the states of the input units to the input
  states(LTUnetwork.input_idx) = inputs;

  % compute the activity propagation
  prop = states * LTUnetwork.connections;
  
  % apply thresholds
  states = double(prop >= LTUnetwork.thresholds);
end

% assign return values
newStates = states;
output = states(LTUnetwork.output_idx);
