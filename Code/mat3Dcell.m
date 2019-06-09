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

function out = mat3Dcell(in)
% MAT3DCELL: converts 3D-matrix to a cell-vector with 2D-entries
%
%   INPUT
%   in: matrix of [M,N,L] = size(in)
%
%   OUTPUT
%   out:  cell-vector with L = length(in) containing 2D-matrices of [M,N] =
%        size(out{1})
%
% ----------------------------------------------------------------------- %


if size(in,3) <= 1
    error('Matrix must have 3 dimensions')
end

out = squeeze(mat2cell(in, size(in,1), size(in,2), ones(1,size(in,3))));
