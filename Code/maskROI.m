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

function mask = maskROI(im)
% MASKROI: finds a logical mask of a cell nucleus in the provided image
% either semiautomatically or by user-provided polygon
%
%   INPUT
%   im:   single input image
%
%   OUTPUT
%   mask: structure with fields:
%       mask.msk: logical mask with size(mask.msk)=size(im)
%       mask.idx: x-coordinates of boundary of logical mask
%       mask.idy: y-coordinates of boundary of logical mask
% ----------------------------------------------------------------------- %

% convert to grayscale
if size(im,3) > 1
    im = rgb2gray(im);
end

%% try to mask cells automatically
% blur image
I_eq = adapthisteq( im / max(im(:)) );
fil = fspecial('disk', 5);
I_eq = imfilter(I_eq, fil, 'replicate');

% convert to black-white image
bw = imbinarize(I_eq, graythresh(I_eq));

% fill holes
bw2 = imfill(bw, 'holes');
bw3 = imopen(bw2, ones(5,5));
bw4 = bwareaopen(bw3, 40);

% get boundary
bound = bwboundaries(bw4);

done = 0;
while ~done
    
    % plot what we found
    figure('unit', 'normalized', 'position', [0.01 0.4 0.4 0.5])
    imagesc(im), colormap gray, hold on
    title('Segmented nuclei. Choose by clicking.')
    disp('> Segmented nuclei. Choose by clicking.')
    disp('> Alternatively, click outside segmentation to mask manually.')
    for k = 1:length(bound)
        plot(bound{k}(:,2), bound{k}(:,1), 'g')
    end
    
    found = 1;
    [xclick, yclick, button] = ginput(1);
    % nuclei can only be chosen with the left mouse button
    if isempty(button) || button~=1
        close gcf, pause(1)
        break;
    else
        for k = 1:length(bound) % check if user clicked within an automatically selected nucleus
            [in,on] = inpolygon(xclick, yclick, bound{k}(:,2), bound{k}(:,1));
            if in | on % if the click was within or on the boundary
                plot(bound{k}(:,2), bound{k}(:,1), 'r')
                
                mask.msk = poly2mask(bound{k}(:,2), bound{k}(:,1), size(im,1), size(im,2));
                mask.idx = bound{k}(:,2);
                mask.idy = bound{k}(:,1);
                found = 1;
                break;
            else % if it was outside
                found = 0;
            end
        end
        if found == 0
            title('> Mask your nucleus manually.')
            disp('> Mark your polygon points with the left mouse button. ')
            disp('> Double-click in the nucleus when finished.')
            [mask.msk, mask.idx, mask.idy] = roipoly(scale_image(im, 0, 1));
            % After masking, return to old plot
            imagesc(im), colormap gray, hold on
            title('Segmented nuclei.')
            % plot automatically segmented nucleus boundaries
            for k = 1:length(bound)
                plot(bound{k}(:,2), bound{k}(:,1), 'g')
            end
            % plot user selected boundary
            plot(mask.idx, mask.idy, 'r')
        end
        title('Segmented nuclei.')
        
    end
    % ask user if he did a mistake and want to do mask again
    done = input('> Keep selected nucleus? [0 - No, repeat masking; 1 - Yes, proceed.] ');
    % close current figure
    close(gcf)
end
