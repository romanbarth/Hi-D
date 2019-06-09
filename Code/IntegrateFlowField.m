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

function [xp, yp] = IntegrateFlowField(x, y, u, v, mask_nuc)
% INTEGRATEFLOWFIELD integrates the velocity fields u (and v) to get the
% trajectories stored as location information in xp and yp
%
%   INPUT
%   x:  array of size of the frames in im with x-indices of pixels
%   y:  array of size of the frames in im with y-indices of pixels
%   u:  cell vector with length length(im)-1 with the x-component of the
%       computed flow field as returned by OpticalFlow.m
%   v:  cell vector with length length(im)-1 with the y-component of the
%       computed flow field as returned by OpticalFlow.m
%   OUTPUT
%   xp: 3D array with size of u and length = length(u)+1. The array
%       consists of the x-position of every pixel for time t
%   yp: 3D array with size of u and length = length(u)+1. The array
%       consists of the y-position of every pixel for time t.
%
% ----------------------------------------------------------------------- %


% initialize
xp = zeros(size(u{1},1), size(u{1},2), length(u)+1);
yp = zeros(size(u{1},1), size(u{1},2), length(u)+1);
xp(:,:,1) = x;
yp(:,:,1) = y;

% create grid for interpolation
[xx, yy] = ndgrid(1:size(u{1},2), 1:size(u{1},1));

warning('off')

disp('Integration..')
f = waitbar(0, 'Integration..');

for t = 1:length(u)
    % create interpolant
    vx_int = griddedInterpolant(xx, yy, u{t}', 'pchip', 'none');
    vy_int = griddedInterpolant(xx, yy, v{t}', 'pchip', 'none');
    
    % add interpolated displacement to previos trajectory position
    xp(:,:,t+1) = xp(:,:,t) + vx_int(xp(:,:,t), yp(:,:,t));
    yp(:,:,t+1) = yp(:,:,t) + vy_int(xp(:,:,t), yp(:,:,t));
    
    % in case of NaN-values, interpolate them
    xp(:,:,t+1) = inpaint_nans(xp(:,:,t+1), 4);
    yp(:,:,t+1) = inpaint_nans(yp(:,:,t+1), 4);
    
    % apply mask to trajectories
    xp(:,:,t+1) = xp(:,:,t+1) .* mask_nuc;
    yp(:,:,t+1) = yp(:,:,t+1) .* mask_nuc;
    
    waitbar(t/length(u), f, 'Integration..');
    
end
close(f)