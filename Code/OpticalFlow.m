%
% HiD
% ----------------------------------------------------------------------- %
%
%
% developed at:
%       Laboratoire de Biologie Moléculaire Eucaryote (LBME),
%       Centre de Biologie Intégrative (CBI), CNRS;
%       University of Toulouse, UPS; 31062
%       Toulouse; France
%
% ----------------------------------------------------------------------- %

function [x,y,u,v] = OpticalFlow(im, mask)
% OPTICALFLOW: computes Optical Flow for given image series using a Optical
% Flow algorithm by Sun et al:
%
%   Sun,D., Roth,S. and Black,M.J. (2014) A quantitative analysis of
%   current practices in optical flow estimation and the principles behind
%   them. Int. J. Comput. Vis., 106, 115–137
%
%   INPUT
%   im:   cell-vector containing the time series frames. Each cell entry is
%         a 2D array
%   mask: structure with fields .msk, .idx and .idy as given by maskROI.m
%
%   OUTPUT
%   x:    array of size of the frames in im with x-indices of pixels
%   y:    array of size of the frames in im with y-indices of pixels
%   u:    cell vector with length length(im)-1 with the x-component of the
%         computed flow field
%   v:    cell vector with length length(im)-1 with the y-component of the
%         computed flow field
%
% ----------------------------------------------------------------------- %

% initialize
numIm = length(im);
u = cell(1, numIm-1);
v = u;

% create mesh on which flow field is evaluated, i.e. the centers of each image pixel
[x,y] = meshgrid(1:size(im{1},2), 1:size(im{1},1));

% Optical Flow
disp('Optical Flow..')
f = waitbar(0, 'Optical Flow..');
tic
for k = 1:numIm-1
    
    % apply Optical Flow to every pair of subsequent frames
    uv = estimate_flow_interface(im{k}, im{k+1}, mask.msk, 'classic+nl-fast');
    u{k} = double(uv(:,:,1));
    v{k} = double(uv(:,:,2));
    
    % apply mask (including nucleoli to flow field
    u{k} = u{k}.*mask.msk;
    v{k} = v{k}.*mask.msk;
    
    % filter to suppress artifacts at borders
    [u{k}, v{k}] = FilterFlowField(u{k}, v{k}, 6);
    
    % interpolate resulting NaNs
    if sum(isnan(u{k}(:))) > 0
        u{k} = inpaint_nans(u{k}, 4);
    end
    if sum(isnan(v{k}(:))) > 0
        v{k} = inpaint_nans(v{k}, 4);
    end
    
    waitbar(k/(numIm-1), f, 'Optical Flow..');
end
close(f)
