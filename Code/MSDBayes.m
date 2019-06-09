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

function Bayes = MSDBayes(MSD, dT)
% MSDBAYES: applies a Bayesian inference to a small subset of up to 10
% trajectories and thereby chooses the best fitting model considering the
% model complexity and the corresponding parameters. Model selection and
% parameters are mapped onto the projected nuclear volume.
%
%   INPUT
%   MSD: MSD cell-vector as given by MSDcalculation.m
%   dT:  time lag in sec
%
%   OUTPUT
%   Bayes: structure containing the fields
%            - model: Model selection by labels (1 - D, 2 - DA, 3 - V
%                     4 - DV, 5 - DAV)
%            - Se:    MSD offset
%            - D:     Diffusion constant
%            - A:     Anomalous exponent
%            - V:     Velocity
%
% ----------------------------------------------------------------------- %

% set models to choose from
msd_params.models = {'DE','DAE','VE','DVE','DAVE'};
NumModels = length(msd_params.models);

% time vector
timelags = dT : dT : round(0.5*length(MSD))*dT;

% number of trajectories to process
amount = sum(~isnan(MSD{1}(:)));

% initialize output
prob  = zeros(size(MSD{1},1), size(MSD{1},2), NumModels);
model = zeros(size(MSD{1})); 
Se    = model;
D     = model; 
A     = model; 
V     = model; 

% loop through pixels
disp('Bayesian inference..')
f = waitbar(0, 'Bayesian inference..');

count = 0;
tic
for row = 1:size(MSD{1},1)
    for col = 1:size(MSD{1},2)        
        if ~isnan(MSD{1}(row, col))
            
            count = count + 1;
            waitbar(count/amount, f, 'Bayesian inference..');

            % get 3x3 neighborhood around central pixel
            nh = 1;
            if row-nh < 1,              xs = row; else, xs = row-nh; end
            if row+nh > size(MSD{1},1), xe = row; else, xe = row+nh; end
            if col-nh < 1,              ys = col; else, ys = col-nh; end
            if col+nh > size(MSD{1},2), ye = col; else, ye = col+nh; end
            
            MSD_curves = cellfun(@(x) x(xs:xe,ys:ye), MSD, 'UniformOutput', false);
            
            % put in right format
            MSD_curves = cellfun(@(x) x(:)', MSD_curves, 'UniformOutput', false);
            MSD_curves = cell2mat(MSD_curves');
            
            % do not take MSDs into account with NaNs
            MSD_curves(:,any(isnan(MSD_curves), 1)) = [];
            
            % Take only half of the MSD curve
            MSD_curves = MSD_curves(1:round(size(MSD_curves,1)/2),:);
            
            % throw error if only 1 curve is available
            if size(MSD_curves,2) < 2 ||  sum(sum(abs(repmat(mean(MSD_curves,2),[1,size(MSD_curves,2)])-MSD_curves))) < 1e-6                
                results.ERROR = true;
            else
                results = msd_curves_bayes(timelags, MSD_curves, msd_params);                
                results.ERROR = false;
            end
            
            
            if ~results.ERROR
                
                % extract model probabilities and find maximum probability
                for jj = 1:size(prob,3)
                    prob(row, col, jj) = real(eval(['results.mean_curve.' msd_params.models{jj} '.PrM']));
                end
                prob(isnan(prob)) = 0;
                
                [~, I] = max(reshape(prob(row, col, :),1,[]));
                if all(reshape(prob(row, col, :),1,[]) < 1e-6) || reshape(prob(row, col, I),1,[]) <= 0.9
                    I = NaN;
                end
                                
                %% assign values to pixels for the chosen model
                if ~isnan(I)
                    if isfield(eval(['results.mean_curve.' msd_params.models{I}]),'C')
                        Se(row, col) = eval(['results.mean_curve.' msd_params.models{I} '.C']);
                    end
                    if isfield(eval(['results.mean_curve.' msd_params.models{I}]),'E')
                        Se(row, col) = eval(['results.mean_curve.' msd_params.models{I} '.E']);
                    end
                    if isfield(eval(['results.mean_curve.' msd_params.models{I}]),'D')
                        D(row, col) = eval(['results.mean_curve.' msd_params.models{I} '.D']);
                    end
                    if isfield(eval(['results.mean_curve.' msd_params.models{I}]),'A')
                        A(row, col) = eval(['results.mean_curve.' msd_params.models{I} '.A']);
                    end                    
                    if isfield(eval(['results.mean_curve.' msd_params.models{I}]),'V')
                        V(row, col) = eval(['results.mean_curve.' msd_params.models{I} '.V']);
                    end
                    
                    % chosen model
                    model(row, col) = I;
                end % if model found
            end % if no error thrown
        end % if MSD is not NaN
    end % column-loop
end % row-loop
close(f)

% create output structure
Bayes.model = model;
Bayes.Se    = Se;
Bayes.D     = D;
Bayes.A     = A;
Bayes.V     = V;