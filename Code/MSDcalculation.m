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

function MSD = MSDcalculation(xp, yp, mask, dT)
% MSDCALCUALTION: calculates MSD for every pixel
%
%   INPUT
%   xp:   x-position of every pixel for time t as given by
%         IntegrateFlowField.m
%   yp:   y-position of every pixel for time t as given by
%         IntegrateFlowField.m
%   mask: mask with 0 outside nucleus and inside nucleoli
%   dT:   time lag in sec

%   OUTPUT
%   MSD:  cell-vector with length = size(xp,3)-1 containing the MSD curve
%         at every pixel
%
% ----------------------------------------------------------------------- %

% Prepare mask
mask(mask == 0) = NaN;

% time vector
t = dT : dT : size(xp,3)*dT;

% initilaize output
MSD = cell(1,size(xp,3)-1);

% loop through time lags and temporally average
disp('MSD calculation..')
f = waitbar(0, 'MSD calculation..');

for lag = 1:length(t)-1
    
    d = (xp(:,:,1+lag:end) - xp(:,:,1:end-lag)).^2 + (yp(:,:,1+lag:end) - yp(:,:,1:end-lag)).^2; 
    d(d==0) = NaN;
    
    MSD{lag} = nanmean(d, 3) .* mask;
    
    waitbar(lag/(length(t)-1), f, 'MSD calculation..');
end
close(f)