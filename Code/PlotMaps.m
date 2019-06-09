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

function PlotMaps(im, mask, pixelsize, Bayes)
% PLOTMAPS: plots results in one figure from the main script HiD.m:
% fluorescence image, model selection with colorcode, diffusion constant,
% anomalous exponent and velocity
%
%   INPUT
%   im:        fluorescence image
%   mask:      mask with nucleoli as given by find_nucleoli.m
%   pixelsize: pixelsize in µm
%   Bayes:     Bayesian inference result structure as given by MSDBayes.m
%
% ----------------------------------------------------------------------- %

% create fullscreen figure
f = figure('units', 'normalized', 'outerposition', [0 0 1 1]);

% load colormaps
[cmap_model, cmap_data] = LoadColormaps;

% compute mask boundaries
b = bwboundaries(mask);

% get limits
limits = [1, size(mask,2), 1, size(mask,1)];

% fluorescence image with mask boundaries
s = subplot(2,3,1); hold on
imagesc(im{1})
colormap(gca, gray)
PlotBoundaries(b, 'g')
barlength = scalebar_custom(s, pixelsize, 'color', 'w');
axis(limits)
axis off
title(['Raw image. Scale bar ' num2str(barlength) 'µm'])
hold off

% model selection
s = subplot(2,3,2); hold on
modelRGB = label2rgb(Bayes.model, cmap_model(2:end,:));
imagesc(modelRGB)
colormap(gca, cmap_model)
PlotBoundaries(b, 'k')
scalebar_custom(s, pixelsize, 'color', 'w', 'length', 'barlength');
axis(limits)
axis off
title('Model Selection')
hold off

% model legend
s = subplot(2,3,3); hold on
h = imagesc(0:size(cmap_model,1));
delete(h)
colormap(gca, cmap_model(2:end,:))

% create colorbar
h_bar = colorbar('color', 'k', 'location', 'north');
% set xtick font size to 12
set(h_bar, 'FontSize',12)
% get limits which MATLAB puts automatically
barlimits = h_bar.Limits;

fac = (barlimits(2)-barlimits(1)) / (size(cmap_model,1)-1);
ticks = fac .* (1:size(cmap_model,1)-1) - fac/2;
set(h_bar, 'Ticks', ticks)
ticklabels = {'D','DA','V','DV','DAV'};
set(h_bar, 'TickLabels', ticklabels)
set(h_bar, 'TickLength', h_bar.Position(4))

h_bar.Units = 'normalized';
h_bar.Position = [0.7 0.8 0.2 0.05];
axis off
title('Model selection colorcode')

% D
s = subplot(2,3,4); hold on
imagesc(Bayes.D)
colormap(gca, cmap_data)
PlotBoundaries(b, 'k')
scalebar_custom(s, pixelsize, 'color', 'w', 'length', 'barlength');
axis(limits)
axis off
title('Diffusion constant [µm^2/s]')
hold off

% A
s = subplot(2,3,5); hold on
imagesc(Bayes.A)
colormap(gca, cmap_data)
PlotBoundaries(b, 'k')
scalebar_custom(s, pixelsize, 'color', 'w', 'length', 'barlength');
axis(limits)
axis off
title('Anomalous exponent')
hold off

% V
s = subplot(2,3,6); hold on
imagesc(Bayes.V)
colormap(gca, cmap_data)
PlotBoundaries(b, 'k')
scalebar_custom(s, pixelsize, 'color', 'w', 'length', 'barlength');
axis(limits)
axis off
title('Velocity [µm/s]')
hold off

set(gcf, 'color', 'w')
end

% -------------------------------------------------------------------------

function PlotBoundaries(b, varargin)
if nargin > 1
    linecolor = varargin{1};
else
    linecolor = 'k';
end

for ib = 1:length(b)
    if size(b{ib},1) > 5
        plot(b{ib}(:,2), b{ib}(:,1), '-', 'linewidth', 1.5, ...
            'color', linecolor)
    end
end

end % function

% -------------------------------------------------------------------------

function l = scalebar_custom(data, pixelsize, varargin)

textcolor = 'k';

if isnumeric(data)
    [xmax, ymax] = size(data);
    offx = 0;
    offy = 0;
elseif ishandle(data)
    ax = findall(data, 'type', 'axes');
    xmax = ax.XLim(2)-ax.XLim(1);
    ymax = ax.YLim(2)-ax.YLim(1);
    offx = ax.XLim(1);
    offy = ax.YLim(1);
else
    error('Provide either data or figure handle')
end

% take 10% of the image for the length of the scalebar per default
% round to have integeger micrometer values
l = ceil(min([xmax,ymax])*0.1 * pixelsize); 

% optional input
if isempty(find(strcmp(varargin,'length'), 1))==0
    l = varargin{find(strcmp(varargin,'length'))+1};
end
if isempty(find(strcmp(varargin,'color'), 1))==0
    textcolor = varargin{find(strcmp(varargin,'color'))+1};
end

lpx = l/pixelsize; % length in pixels
len = [xmax*0.05 xmax*0.05+lpx];

lwidth = 4;
plot(len+offx, ones(1,length(len))*0.05*ymax+offy, 'linestyle', '-', 'color', textcolor, 'LineWidth', lwidth);

end % function

% -------------------------------------------------------------------------

function [cmap_model, cmap_data] = LoadColormaps

cmap_model = [  1.0000    1.0000    1.0000
                     0    0.6572         0
                     0    0.4809    1.0000
                0.9284    0.0837    1.0000
                1.0000    0.2295    0.3074
                0.7994    0.8632         0];
            
cmap_data = [        1         1         1;...
                0.2422    0.1504    0.6603;...
                0.2504    0.1650    0.7076;...
                0.2578    0.1818    0.7511;...
                0.2647    0.1978    0.7952;...
                0.2706    0.2147    0.8364;...
                0.2751    0.2342    0.8710;...
                0.2783    0.2559    0.8991;...
                0.2803    0.2782    0.9221;...
                0.2813    0.3006    0.9414;...
                0.2810    0.3228    0.9579;...
                0.2795    0.3447    0.9717;...
                0.2760    0.3667    0.9829;...
                0.2699    0.3892    0.9906;...
                0.2602    0.4123    0.9952;...
                0.2440    0.4358    0.9988;...
                0.2206    0.4603    0.9973;...
                0.1963    0.4847    0.9892;...
                0.1834    0.5074    0.9798;...
                0.1786    0.5289    0.9682;...
                0.1764    0.5499    0.9520;...
                0.1687    0.5703    0.9359;...
                0.1540    0.5902    0.9218;...
                0.1460    0.6091    0.9079;...
                0.1380    0.6276    0.8973;...
                0.1248    0.6459    0.8883;...
                0.1113    0.6635    0.8763;...
                0.0952    0.6798    0.8598;...
                0.0689    0.6948    0.8394;...
                0.0297    0.7082    0.8163;...
                0.0036    0.7203    0.7917;...
                0.0067    0.7312    0.7660;...
                0.0433    0.7411    0.7394;...
                0.0964    0.7500    0.7120;...
                0.1408    0.7584    0.6842;...
                0.1717    0.7670    0.6554;...
                0.1938    0.7758    0.6251;...
                0.2161    0.7843    0.5923;...
                0.2470    0.7918    0.5567;...
                0.2906    0.7973    0.5188;...
                0.3406    0.8008    0.4789;...
                0.3909    0.8029    0.4354;...
                0.4456    0.8024    0.3909;...
                0.5044    0.7993    0.3480;...
                0.5616    0.7942    0.3045;...
                0.6174    0.7876    0.2612;...
                0.6720    0.7793    0.2227;...
                0.7242    0.7698    0.1910;...
                0.7738    0.7598    0.1646;...
                0.8203    0.7498    0.1535;...
                0.8634    0.7406    0.1596;...
                0.9035    0.7330    0.1774;...
                0.9393    0.7288    0.2100;...
                0.9728    0.7298    0.2394;...
                0.9956    0.7434    0.2371;...
                0.9970    0.7659    0.2199;...
                0.9952    0.7893    0.2028;...
                0.9892    0.8136    0.1885;...
                0.9786    0.8386    0.1766;...
                0.9676    0.8639    0.1643;...
                0.9610    0.8890    0.1537;...
                0.9597    0.9135    0.1423;...
                0.9628    0.9373    0.1265;...
                0.9691    0.9606    0.1064;...
                0.9769    0.9839    0.0805];
end % function