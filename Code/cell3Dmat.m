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

function out = cell3Dmat(in)
% CELL3DMAT: converts cell-vector with 2D-entries to 3D-matrix
%
%   INPUT
%   in:  cell-vector with L = length(in) containing 2D-matrices of [M,N] =
%        size(in{1})
%
%   OUTPUT
%   out: matrix of [M,N,L] = size(out)
%
% ----------------------------------------------------------------------- %

 out = zeros([size(in{1}), length(in)]);
 for k = 1:length(in)
     out(:,:,k) = in{k};
 end