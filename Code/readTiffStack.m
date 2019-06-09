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

function im = readTiffStack(directory)
% READTIFFSTACK reads a stack of tiff images
%
%   INPUT
%   directory:  string providing the full path, filename and extension of
%               the file to read in
%
%   OUTPUT
%   im:         cell-vector containing the time series frames. Each cell 
%               entry is a 2D array
%
% ----------------------------------------------------------------------- %

warning('off')
InfoImage = imfinfo(directory);
numIm = length(InfoImage);
im = cell(1, numIm);

obj = Tiff(directory, 'r');
f = waitbar(0, 'Reading in images...');
for i = 1:numIm
    
    waitbar(i/numIm, f, 'Reading in images...');
    obj.setDirectory(i);
    im{i} = obj.read();
    
end
obj.close();
close(f)