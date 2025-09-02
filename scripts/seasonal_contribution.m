%% MATLAB Code for Creating Plots from
% Apoznanski et al., 2025
% Author: Diana Apoznanski

% Analysis notes: 
    % Input (TheBattery_qn_ssjpm.mat) is from from Baranes et al. (2020)'s qn_ssjpm_v4.m    

    % Baranes et al. (2020) output notes:
    % epTotal_qtl --> # exceedances (inverse RP)
    % stTotal_qtl --> storm tide
    % _ann --> separate curve for each year (1000 curves per year)
    % _int --> integrated, no separate calculations per year (1000 curves total, qnSSJPM from lit)
    % total --> combined summer and winter
    % qtl --> only qtls not 1000 curves

clear all; close all; 

%% 1. Joint probability curves

% Load site
siteIx = 1; 
site{1} = 'TheBattery'; 

qnSSJPM_file = char([site{siteIx} '_qn_ssjpm.mat']); load(qnSSJPM_file); 
a = {'etc' 'tc'};


% Which exceedance probability?

EP = 0.01;% EDIT HERE: find index of 0.1 (10 y) or 0.01 (100 y) exceedance level

% Find index where that EP is plotted
exc = find(epGrid == EP); 
% water level to evaluate contribution
wl_level = stTotal_qtl(2,exc); %site 50pct water level at 0.1
n_samps = size(ST_qjp_ann.etc, 3);   % number of Latin Hypercube draws
epGrid  = epGrid(:); % ensure column vector

%% 1. Collapse all years into one long series 

% concatenate all years’ curves into a single “super-curve”
% Dimension order is: years × epGrid × samples
% reshape so that epGrid is still the second dimension, but all years are merged.
etc_all = reshape(permute(ST_qjp_ann.etc, [1 2 3]), [], size(ST_qjp_ann.etc, 2), n_samps);
tc_all  = reshape(permute(ST_qjp_ann.tc,  [1 2 3]), [], size(ST_qjp_ann.tc,  2), n_samps);

% Note: The first dim (years collapsed) is not used in interpolation
% because EP grid is identical for all years.

%% 2. Preallocate contribution results
contribution_all = NaN(n_samps, 1);

%% 3. Loop over LHC draws
for samp = 1:n_samps
    % Take the WL vs EP curve for all years combined for this draw
    % Since EP grid is the same, we average across years to get a representative curve
    etc_curve = squeeze(mean(etc_all(:,:,samp), 1, 'omitnan')); % mean WL at each EP
    tc_curve  = squeeze(mean(tc_all(:,:,samp),  1, 'omitnan'));
    
    % Keep only finite points for interpolation
    finite_etc = isfinite(etc_curve);
    finite_tc  = isfinite(tc_curve);
    
    if sum(finite_etc) >= 2 && sum(finite_tc) >= 2
        % Interpolate: find EP at given water level
        etc_EP = interp1(etc_curve(finite_etc), epGrid(finite_etc), wl_level, 'linear', NaN);
        tc_EP  = interp1(tc_curve(finite_tc),   epGrid(finite_tc),  wl_level, 'linear', NaN);

        if ~isnan(etc_EP) && ~isnan(tc_EP) && (etc_EP + tc_EP) ~= 0
            contribution_all(samp) = etc_EP / (etc_EP + tc_EP);
        end
    end
end

%% 4. Compute percentiles across all 1000 draws
percentiles = prctile(contribution_all(~isnan(contribution_all)), [5 50 95]);

p5_all  = percentiles(1);
p50_all = percentiles(2);
p95_all = percentiles(3);

% convert to percent
p5_percent  = p5_all * 100;
p50_percent = p50_all * 100;
p95_percent = p95_all * 100;

% --- 5. Print result ---
fprintf('%s RP contribution %%: %.2f (%.2f - %.2f)\n', ...
        num2str(1/EP), p50_percent, p5_percent, p95_percent);


% For map figure 2 in Apoznanski et al. 2025 this was repeated and recorded
% for each site, then plotted on a map.