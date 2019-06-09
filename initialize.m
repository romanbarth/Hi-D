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

function initialize
% INITIALIZE adds required subfolders to matlab path

disp('Initialization...')

here = mfilename('fullpath');
[path, ~, ~] = fileparts(here);
addpath(genpath(path));


end
