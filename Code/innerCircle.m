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

function [maskc, radius] = innerCircle(mask)
% INNERCIRCLE: finds the biggest inner circle of masked region, assuming 
% the center is in the middle of the picture. Therefore, the maskshould be 
% centered in the image, i.e. the centroid of the structure should be the 
% middle of the picture.
%
%   INPUT
%   mask:   binary mask containing the centered structure
%
%   OUTPUT
%   maskc:  binary mask containing the largest circle fitting into the
%           selected are in mask
%   radius: radius of the circle in pixels
%
% ----------------------------------------------------------------------- %

% find middle of picture
middle = size(mask)/2;

% trace boundaries
bound = bwboundaries(mask);

% find minimum distance from midpoint (=centroid) to boundary
[radius, ~] = min((sum( (bound{1}-repmat(middle,size(bound{1},1),1)).^2 ,2)).^(1/2));

% take values which are around the centroid and closer than the radius
[x,y] = meshgrid(1:size(mask,2), 1:size(mask,1));
r = ( (y-middle(1)).^2 + (x-middle(2)).^2 ).^(1/2);
maskc = double(r <= radius);
end
