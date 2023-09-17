% dataStructures - lists the data structures used in the SaliencyToolbox.
%
% DATA STRUCTURES USED IN THE SALIENCYTOOLBOX
%
% Global variables
%    IS_INITIALIZED: flag that initializeGlobal was called.
%    IMG_EXTENSIONS: cell arrays with possible extensions for image files.
%         DEBUG_FID: file identifier for debugMsg output.
%
%  See also initializeGlobal, declareGlobal, debugMsg.
%
%
% Image - stores information about an image.
%   filename: the filename.
%       data: the image data (UINT8 or double)
%             Each image structure has to contain the filename or the data
%             field. It can have both.
%       type: some text label.
%       size: the size of the image.
%       dims: the number of dimensions of the image (2 or 3).
%       date: time stamp.
%
% See also initializeImage.
%
%
% Map - 2d data structure with extra information.
%     origImage: Image from which this map was computed.
%         label: text label identying the map.
%          data: 2d array with the map data.
%          date: time stamp.
%    parameters: parameters used for generating this map.
%
% See also displayMap, displayMaps.
%
%
% Pyramid - a multi-resolution pyramid for a particular feature.
%    origImage: the source image.
%        label: text label denoting the feature.
%         type: type of subsampling, one of: 'dyadic','sqrt2','TopDown'.
%       levels: vector of maps containing the levels of this pyramid.
%         date: time stamp.
%
% See also makeFeaturePyramids, displayPyramid, runSaliency.
%
%
% SaliencyParams - set of parameters used for generating a saliency map.
%               foaSize: size of the focus of attention for disk-IOR.
%           pyramidType: 'dyadic' or 'sqrt2'.
%              features: cell array of the features to be used for saliency computation
%                        possible values: 'Color', 'Intensities', 'Orientations', 'Skin','TopDown'.
%               weights: vector of weights for each feature (same length as features)
%               IORtype: type of inhibition of return, one of: 'shape','disk','None'.
%             shapeMode: one of: 'None','shapeSM','shapeCM','shapeFM','shapePyr'.
%           levelParams: structure with pyramid level parameters.
%              normtype: Map normalization type, one of: 'None','LocalMax','Iterative'.
%               numIter: Number of iterations for 'Iterative' normtype.
%             useRandom: Use random jitter (1) or not (0) for converting coodinates.
%    segmentComputeType: Method for shape segmentation, one of: 'Fast','LTU'.
%              IORdecay: decay rate of the inhibitive conductance responsible for inihibiiton 
%                        of return per simulation step of 0.1 ms.
%         smOutputRange: saliency map output in Amperes (1e-9).
%             noiseAmpl: amplitude of random noise (1e-17).
%            noiseConst: amplitude of contant noise (1e-14).
%           gaborParams: structure with parameters for Gabor orientation filters.
%             oriAngles: vector with orientation angles (in degrees).
%        oriComputeType: 'efficient' (default) or 'full'
%                        'efficient' only computes orientation filters for the levels that are 
%                                    actually going to be used in the center-surround computation
%                       'full' computes the orientation filters for all levels
%    visualizationStyle: style used for visualizing attended locations, 
%                        one of: 'Contour', 'ContrastModulate', 'None'.
%         exclusionMask: struct of type map or 2d mask of numeric or logical type
%                        regions where exclusionMask is ~= 0 are excluded from the saliency 
%                        computations by setting all feature maps to 0 in these areas. The 
%                        mask is automatically resized to the size of the feature maps.
%
% See also diskIOR, makeGaussianPyramid, makeSaliencyMap, applyIOR, estimateShape,
%          centerSurround, maxNormalize, winnerToImgCoords, makeGaborFilter, 
%          defaultGaborParams, defaultLevelParams, plotSalientLocation.
%
%
% levelParams - a structure with parameters for pyramid levels for
%               center-surround operations
%     minLevel: lowest pyramid level (starting at 1) for center-surround computations.
%     maxLevel: highest pyramid level for center-surround.
%     minDelta: minimum distance (levels) between center and surround.
%     maxDelta: maximum distance (levels) between center and surround.
%     mapLevel: pyramid level for all maps, including the saliency map.
%
% See also defaultLevelParams, centerSurround, winnerToImgCoords.
%
%
% gaborParams - a structure with parameters for Gabor orientation filters.
%       filterPeriod: the period of the filter in pixels.
%         elongation: the ratio of length versus width.
%         filterSize: the size of the filter in pixels.
%             stddev: the standard deviation of the Gaussian envelope in pixels.
%             phases: the phase angles to be used.
%
% See also defaultGaborParams, makeGaborFilter, gaborFilterMap, makeOrientationPyramid.
%
%
% hueParams - describes 2d Gaussian color distribution in CIE space.
%        muR: mean value in the CR direction.
%       sigR: standard deviation in the CR direction.
%        muG: mean value in the CG direction.
%       sigG: standard deviation in the CG direction.
%        rho: correlation coefficient between CR and CG.
%
% See also hueDistance, makeHuePyramid, skinHueParams.
%
%
% saliencyData - a vector of structures for each feature with additional
%                information from computing the saliency map.
%      origImage: Image structure of the input image.
%          label: the feature name.
%            pyr: a vector of pyramids for this feature.
%             FM: a vector of feature maps.
%       csLevels: the center and surround levels used to
%                 compute the feature maps from the pyramids.
%             CM: the conspicuity map for this feature.
%           date: time stamp.
%
% See also makeSaliencyMap, estimateShape, runSaliency.
%
%
% shapeData - information about the shape of the attended regions.
%       origImage: the Image structure for the source image.
%          winner: the winning location in saliency map coordinates.
%      winningMap: the map for the most salient feature at the winner location.
%         iorMask: the mask used for shape-based inhibition of return.
%       binaryMap: a binary map of the attended region.
%    segmentedMap: the winning map segmented by the binary map.
%        shapeMap: a smoothed version of segmentedMap.
%            date: time stamp.
%
% See also estimateShape, shapeIOR, applyIOR, plotSalientLocation, runSaliency.
%
%
% WTA - a winner-take-all neural network.
%       sm: LIF neuron field for input from the saliency map.
%      exc: excitatory LIF neurons field.
%    inhib: inhibitory inter-neuron.
%
% See also initializeWTA, evolveWTA.
%
%
% LIF - leaky integrate and fire neuron (field).
%     timeStep: time step for integration (in sec).
%        Eleak: leak potential (in V).
%         Eexc: potential for excitatory channels (positive, in V).
%         Einh: potential for inhibitory channels (negative, in V).
%        Gleak: leak conductivity (in S).
%         Gexc: conductivity of excitatory channels (in S).
%         Ginh: conductivity of inhibitory channels (in S).
%    GinhDecay: time constant for decay of inhibitory conductivity (in S).
%       Ginput: input conductivity (in S).
%      Vthresh: threshold potential for firing (in V).
%            C: capacity (in F).
%         time: current time (in sec).
%            V: current membrane potential (in V) - can be an array for several neurons.
%            I: current input current (in A) - can be an array for several neurons.
%     DoesFire: neuron can (1) or cannot (0) fire.
%
% See also defaultLeakyIntFire, evolveLeakyIntFire, initializeWTA.
%
%
%   LTUnetwork - a network of N linear threshold units.
%    connections: N x N weight matrix, a sparse matrix.
%     thresholds: 1 x N vector with thresholds for the units.
%      input_idx: the indices of all input units in the network.
%     output_idx: the indices of all output units in the network.
%       numCells: the number of units.
%          label: a text label fo the network.
%
% See also LTUsimulate, LTUsegmentMap, makeLTUsegmentNetwork.

% This file is part of the SaliencyToolbox - Copyright (C) 2006-2013
% by Dirk B. Walther and the California Institute of Technology.
% See the enclosed LICENSE.TXT document for the license agreement. 
% More information about this project is available at: 
% http://www.saliencytoolbox.net

more on;
help(mfilename);
more off;
