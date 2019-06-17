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

function mask_nuc = find_nucleoli(im, mask)
% FIND_NUCLEOLI finds boundaries of nucleoli by user aided thresholding.
% Found elements smaller than 10, bigger than the nuclear scope and outside
% the nuclear of interested are rejected.
%
%   INPUT
%   im:      image to process (given as array)
%
%   OUTPUT
%   mask_nuc: logical mask containing zeros in nucleoli and ones otherwise
%
% ----------------------------------------------------------------------- %

% initialize
disp('> Mask nucleoli manually..')
im = double(im);
thresh = 0;

% show original image and masked nuclei next to each other
figure('unit', 'normalized', 'position', [0.01 0.4 0.99 0.5])
subplot(1,2,1)
imagesc(im), colormap('gray');
colorbar


while ~isempty(thresh)
    
    thresh = input('> Type threshold [ENTER to keep current value]: ');
    
    if ~isempty(thresh)
        mask_nuc = zeros(size(im));
        
        bw = im > thresh;
        B = bwareaopen(bw, 30);
        B = bwboundaries(B, 4);
        
        
        subplot(1,2,2)
        imagesc(im .* bw)
        hold on
        for k = 1:length(B)
            boundary = B{k};
            [in,on] = inpolygon(boundary(:,1), boundary(:,2), mask.idy, mask.idx);
            
            % take only nuleoli which have boundaries of at least 10 length and
            % which do not fill the complete image
            if size(boundary,1) > 10 && size(boundary,1) < length(mask.idx) && any(in | on)
                plot(boundary(:,2), boundary(:,1), 'y', 'LineWidth', 2)
                mask_nuc = mask_nuc + poly2mask(boundary(:,2), boundary(:,1), size(mask_nuc,1), size(mask_nuc,2));
            end
        end
    end
end

if exist('mask_nuc', 'var')
    mask_nuc(mask_nuc ~= 0) = 1;
    mask_nuc = ~mask_nuc;
else
    mask_nuc = ones(size(im));
end

close gcf