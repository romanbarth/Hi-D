%
% Dense Flow reConstruction and Correlation (DFCC)
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

function [ufilt, vfilt] = FilterFlowField(u, v, factor)
% FILTERFLOWFIELD: filters the resulting flow field by setting all
% components which are more than factor*std away from the mean of the
% corresponding flow component (x- or y-component respectively) to NaN
%
%   INPUT
%   u:      cell vector with length length(im)-1 with the (unfiltered) 
%           x-component of the computed flow field 
%   v:      cell vector with length length(im)-1 with the (unfiltered) 
%           y-component of the computed flow field 
%   factor: components are filtered out which are more than factor*std away 
%           from the mean of the corresponding flow component
%
%   OUTPUT
%   ufilt:  cell vector with length length(im)-1 with the (filtered) 
%           x-component of the computed flow field. Filtered components are
%           set to NaN
%   vfilt:  cell vector with length length(im)-1 with the (filtered) 
%           y-component of the computed flow field . Filtered components are
%           set to NaN
%
% ----------------------------------------------------------------------- %


% determine mean of flow fields
umean = nanmean(u(:));
vmean = nanmean(v(:));

% determine range of values to exlude
ustd = nanstd(u(:)) * factor;
vstd = nanstd(v(:)) * factor;

u_accepted = [umean+ustd; umean+ustd; umean-ustd; umean-ustd];
v_accepted = [vmean+vstd; vmean-vstd; vmean-vstd; vmean+vstd];

% locate values within the given range
ok = inpolygon(u, v, u_accepted, v_accepted);

% set points which do not fall in the range to NaN and return
u(~ok) = NaN;
v(~ok) = NaN;
ufilt = u;
vfilt = v;
