%
% Hi-D
% ----------------------------------------------------------------------- %
%
% Reference to the publication:
%   Shaban, H.; Barth, R.; Recoules, L.; Bystricky, K.; Hi-D: Nanoscale mapping of nuclear dynamics in single living cells. Genome Biology (2020)
%
% developed at:  
%       Laboratoire de Biologie Moléculaire Eucaryote (LBME), 
%       Centre de Biologie Intégrative (CBI), CNRS; 
%       University of Toulouse, UPS; 31062 
%       Toulouse; France
%
% ----------------------------------------------------------------------- %

function [im, numIm, mask, mask_nuc] = Preprocessing(directory)
% PREPROCESSING: loads image series from directory, sets mask 
% semiautomatically, centers and crops image series and mask and does 
% filtering to prepare image series for OpticalFlow.m
%
%   INPUT
%   directory: string providing the full path, filename and extension of
%              the file to read in
%
%   OUTPUT
%   im:        cell-vector containing the time series frames. Each cell 
%              entry is a 2D array
%   numIm:     number of images in the file
%   mask:      structure with fields (as returned by maskROI.m):
%                  mask.msk: logical mask with size(mask.msk)=size(im)
%                  mask.idx: x-coordinates of boundary of logical mask
%                  mask.idy: y-coordinates of boundary of logical mask
%   mask_nuc:  logical mask containing zeros in nucleoli and ones otherwise
%
% ----------------------------------------------------------------------- %

% load images
disp('Reading in...')
im = loadimages(directory);
numIm = length(im);

% convert images to uint8 (scale between 0 and 255)
im = mat3Dcell(scale_image(cell3Dmat(im), 0, 255));

%% Mask cell semimanually
mask = maskROI(im{1});
pause(0.2) % wait until figure is closed

%% crop and translate mask and images
% crop image by mask boundaries
left = round(min(mask.idx) - 15); if left < 1, left = 1; end
right = round(max(mask.idx) + 15); if right > size(im{1},2), right = size(im{1},2); end
down = round(min(mask.idy) - 15); if down < 1, down = 1; end
up = round(max(mask.idy) + 15); if up > size(im{1},1), up = size(im{1},1); end

rect = [left, down, right-left, up-down];
mask.msk = imcrop(mask.msk, rect);

% get position of the centroid of the mask
c = regionprops(mask.msk,'centroid');
translation = round([size(mask.msk,2)/2-c.Centroid(1), size(mask.msk,1)/2-c.Centroid(2)]);
% translate mask
mask.msk = imtranslate(mask.msk, translation);
% update boundaries
bound = bwboundaries(mask.msk);
mask.idx = bound{1}(:,2);
mask.idy = bound{1}(:,1);

% crop and translate images
disp('Cropping and centering...')
for imk = 1:numIm
    im{imk} = imtranslate(imcrop(im{imk}, rect), translation);
end

% mask out nucleoli
mask_nuc = find_nucleoli( mean(cell3Dmat(im),3), mask );
mask_nuc = mask_nuc .* mask.msk; % apply boundary of cell also
im = cellfun(@(x) x.*mask_nuc, im, 'uniformoutput', false);
