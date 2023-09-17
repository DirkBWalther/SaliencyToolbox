% skinHueParams - returns a parameter set for skin hue.
%
% params = skinHueParams
%    Returns a set of hue parameters for skin hue. These
%    parameters were derived from the statistics over 
%    3947 faces in 1153 images from the word wide web. 
%    They were used as a benchmark in:
%    Walther, D., Serre,T., Poggio, T., Koch, C., 2005.
%    Modeling feature sharing between object detection
%    and top-down attention [abstract]. Journal of
%    Vision 5(8), 1041a.
%
%    The details are published in appendix A.4 of Dirk Walther's PhD thesis:
%      Dirk Walther (2006). Interactions of visual attention and object recognition: 
%      Computational modeling, algorithms, and psychophysics. Ph.D. thesis.
%      California Institute of Technology. 
%      http://resolver.caltech.edu/CaltechETD:etd-03072006-135433.
%
%    and in this book chapter:
%      Dirk B. Walther & Christof Koch (2007). Attention in 
%      Hierarchical Models of Object Recognition. In P. Cisek, 
%      T. Drew & J. F. Kalaska (Eds.), Progress in Brain Research: 
%      Computational Neuroscience: Theoretical insights into brain 
%      function. Amsterdam: Elsevier.
%
% See also hueDistance, makeHuePyramid.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

function params = skinHueParams

params.muR = 0.434904;
params.muG = 0.301983;
params.sigR = 0.053375;
params.sigG = 0.024349;
params.rho = 0.5852;
