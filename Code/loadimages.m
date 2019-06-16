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

function im = loadimages(directory)
% LOADIMAGES: loads all images of a given file
%
%   INPUT
%   directory:  string providing the full path, filename and extension of
%               the file to read in
%
%   OUTPUT
%   im:          cell-vector containing the time series frames. Each cell
%                entry is a 2D array
%
% ----------------------------------------------------------------------- %

% look in directory what to find
files = dir(directory);
ext = cell(1,length(files));

% extract fileending
count = 0;
for ii = 1:length(files)
    if length(files(ii).name)>4
        count = count+ 1;
        ext{count} = files(ii).name(end-3:end);
    end
end

% take only valid endings: tif, bmp and jpg
ext = cellfun(@(x) num2str(x(:)'),ext,'UniformOutput',false);
ext = ext(~cellfun('isempty',ext));
ending = {'.tif', '.bmp', '.jpg','.tiff','.TIF','.BMP','.TIFF','.JPG',...
    '.jpeg','.JPEG'}; % tif stacks are included in *.tif
isthere = zeros(1, length(ending));
for j = 1:length(ending)
    for k = 1:length(ext)
        if strfind(ext{k}, ending{j})
            isthere(j) = 1;
        end
    end
end

% if there is no file with the matching ending, return an error.
if ~any(isthere)
    error('No image file found')
end

vec = 1:length(ending);
ind = vec==min(vec(isthere~=0));

% see if file is multipage or single images
if ~isempty(files)
    if ispc
        bsi = strfind(directory, '\');
    else
        bsi = strfind(directory, '/');
    end
    singleImages = false;
    for k = 1:length(files)
        try
            imfinfo([directory(1:bsi(end)) files(k).name]);
            break;
        catch ME
            if k == length(files)
                singleImages = true;
            end
        end
    end
end

% Divide two cases: single images
if singleImages % can be RGB image, so take 3 as upper limit
    % read images in
    count = 1;
    ext = ending{ind};
    for ii=1:length(files)
        if ~isempty(strfind(files(ii).name, ext))
            fname{count} = files(ii).name;
            count = count + 1;
        end
    end
    
    num_images = length(fname);
    im = cell(1, num_images);
    
    if ispc
        f = waitbar(0, 'Reading in images...');
        for ii = 1:num_images
            waitbar(ii/num_images, f, 'Reading in images...');
            im{ii} = double(imread([directory '\' fname{ii}]));
        end
        close(f)
    else
        f = waitbar(0, 'Reading in images...');
        for ii = 1:num_images
            waitbar(ii/num_images, f, 'Reading in images...');
            im{ii} = double(imread([directory '/' fname{ii}]));
        end
        close(f)
    end
else % for multipage tiffs, use just readTiffStack.m
    im = readTiffStack([directory(1:bsi(end)) files(1).name]);
end