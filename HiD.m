%
% HiD Interface
% ----------------------------------------------------------------------- %
%
%
% Demo for example data (U2OS cells labeled by DNA-SiR of size
% 310 pixels x 213 pixels x 150 frames).
% The data is a part of the entire dataset of size
% 1024 pixels x 1024 pixels x 150 frames (65 nm pixel size and 5 fps).
%
% The example data takes ~2h 20 min to process on following system:
%       Intel(R) Core(TM) i7-6700IQ CPU @ 2.60 GHz 2.60 Ghz
%       16.0 Gb RAM
%
% developed at:
%       Laboratoire de Biologie Mol�culaire Eucaryote (LBME),
%       Centre de Biologie Int�grative (CBI), CNRS;
%       University of Toulouse, UPS; 31062
%       Toulouse; France
%
% ----------------------------------------------------------------------- %

close all
clearvars

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             USER INPUT                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set parameters
% give the path to the file to analyse
filepath = pwd;
if ispc
    directory = [filepath '\U2OS_DNA_Serum_example_data.tif'];
else
    directory = [filepath '/U2OS_DNA_Serum_example_data.tif'];
end

% pixel size in micrometer
pixelsize= 0.065;

% acquisition time per frame in seconds
dT = 0.2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            START SCRIPT                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Search path
initialize % add all required paths to the Matlab path

%% save date and time for later
cstart = datestr(now); % get start time
datee = datestr(now);
datee(datee==':') = '-';

%% load images, set mask and filter noise (blurring)
[im, numIm, mask, mask_nuc] = Preprocessing(directory);
disp('Starting calculations...')

%% calculate velocity field
[x, y, u, v] = OpticalFlow(im, mask);
% apply nucleolus mask and convert displacement to SI units
u = cellfun(@(x) x .* mask_nuc * pixelsize, u, 'uniformoutput', false);
v = cellfun(@(x) x .* mask_nuc * pixelsize, v, 'uniformoutput', false);

%% integrate velocity field
[xp, yp] = IntegrateFlowField(x, y, u, v, mask_nuc);

%% calculate MSD
MSD = MSDcalculation(xp, yp, mask_nuc, dT);

%% Bayesian inference for MSD classification and regression
Bayes = MSDBayes(MSD, dT);

%% save data
if ispc
    save([filepath '\HiD_Analysis_' convertDate(datee) '.mat'])
else
    save([filepath '/HiD_Analysis_' convertDate(datee) '.mat'])
end

%% plot resulting parameter maps: fluorescence image, model selection, D, alpha, V
PlotMaps(im, mask_nuc, pixelsize, Bayes)

cend = datestr(now);
disp('Hi-D analysis finished!')
disp(['Started:  ' cstart])
disp(['Finished: ' cend])
% ----------------------------------------------------------------------- %