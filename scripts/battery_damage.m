% Economic Analysis for the Battery site from Apoznanski et al. 2025
% Author: Diana Apoznanski (diana.apoznanski@rutgers.edu)
% 
% Notes: 
% 
% This code can be used to reproduce the interpolation of the damage
% curve onto quasi nonstationary skew surge joint probability (qn-SSJPM) 
% curves at The Battery NOAA tide
% gauge (https://tidesandcurrents.noaa.gov/stationhome.html?id=8518750).
%
% Inputs: 
% 
% 1. TheBattery_qn_ssjpm.mat (the output of qn_ssjpm_v4.m 
% by Hannah Baranes from Baranes et al. (2020)).
% 
% 2. damage_curve_manhattan_property_area_elevation.csv
% (the elevation and damage curve from Rasmussen et al. (2020).
% 

%% Economic analysis battery

% ** 1st step is to calcuate the damage curve from the property and
% elevation data from Rasmussen et al. (2020) **

% Here 'damage_curve_manhattan_property_area_elevation.csv' has an 
% extra column than Rasmussen et al. (2020)'s original file, with the
% damage curve values. 

% Read the CSV file into a matrix
data = readtable('damage_curve_manhattan_property_area_elevation.csv');

% Load site
siteIx = 1; 
site{1} = 'TheBattery'; 
qnSSJPM_file = char([site{siteIx} '_qn_ssjpm.mat']); load(qnSSJPM_file); 
a = {'etc' 'tc'};

% Extract elevation (m) and property accumulated sum (Billion USD)
z = data{:,6};
damage_curve = data{:,7};
% Interpolate storm tide values onto the property damage (dollar) grid
prop_etc_interpolated = interp1x_FiniteUnique(z, damage_curve, (ST_qjp_int_qtl.(a{1})(1,:))- 0.758, 0); %add 0.758 to damage curve to make it MSL
prop_tc_interpolated = interp1x_FiniteUnique(z, damage_curve, (ST_qjp_int_qtl.(a{2})(1,:))- 0.758, 0);
prop_tot_interpolated = interp1x_FiniteUnique(z, damage_curve, (stTotal_qtl(1,:))- 0.758, 'linear');
%for uncertainty range, interpolate 5th and 95th pcts
%5pct
prop_etc_interpolated5 = interp1x_FiniteUnique(z, damage_curve, (ST_qjp_int_qtl.(a{1})(2,:))- 0.758, 0); %0.758 accounts for qn_ssjpm being msl and damage curve being higher high water
prop_tc_interpolated5 = interp1x_FiniteUnique(z, damage_curve, (ST_qjp_int_qtl.(a{2})(2,:))- 0.758, 0);
prop_tot_interpolated5 = interp1x_FiniteUnique(z, damage_curve, (stTotal_qtl(2,:))- 0.758, 'linear');
%95pct
prop_etc_interpolated95 = interp1x_FiniteUnique(z, damage_curve, (ST_qjp_int_qtl.(a{1})(3,:))- 0.758, 0); %0.758 accounts for qn_ssjpm being msl and damage curve being higher high water
prop_tc_interpolated95 = interp1x_FiniteUnique(z, damage_curve, (ST_qjp_int_qtl.(a{2})(3,:))- 0.758, 0);
prop_tot_interpolated95 = interp1x_FiniteUnique(z, damage_curve, (stTotal_qtl(3,:))- 0.758, 'linear');


% Calculate the difference between the ETC and TC curves
damage_curve_difference = abs(prop_tc_interpolated - prop_etc_interpolated);

% Find the index of the minimum difference (closest point will be overlap)
[~, ix3] = min(damage_curve_difference);

% Calculate the return period (RP) at the overlap point
% RP = 1/exceedances per year
RP_overlap_d = 1 / epGrid(ix3);

% Display the overlap results
disp(['The RP of the damage overlap point is ', num2str(RP_overlap_d), ' years.']);

%% Create a new figure for plotting exceedances vs property damage
figure; hold on;


% Main lines
plot(prop_etc_interpolated, epGrid, 'b-', 'LineWidth', 1.5);
%plot(prop_etc_interpolated5,epGrid,'b-', 'LineWidth', 1.0);
%plot(prop_etc_interpolated95,epGrid,'b-', 'LineWidth', 1.0);
plot(prop_tc_interpolated, epGrid, 'r--', 'LineWidth', 1.5);
plot(prop_tot_interpolated, epGrid, 'k-', 'LineWidth', 2);
fill([prop_etc_interpolated5 fliplr(prop_etc_interpolated95)],[epGrid fliplr(epGrid)],'b', 'EdgeColor', 'none', 'FaceAlpha', 0.3);
fill([prop_tc_interpolated5 fliplr(prop_tc_interpolated95)],[epGrid fliplr(epGrid)],'r', 'EdgeColor', 'none', 'FaceAlpha', 0.3);
%plot(prop_tc_interpolated5,epGrid,'r-', 'LineWidth', 1.0);
%plot(prop_tc_interpolated95,epGrid,'r-', 'LineWidth', 1.0);


title('Exceedances vs Accumulated Property Damage');
ylabel('Exceedances/yr');
xlabel('Accumulated Property Damage (Billion USD)');
set(gca, 'yscale', 'log');  
grid on;
legend('ETC', 'TC', 'Total','ETC 5-95pct','TC 5-95pct');

%% Calculate Average Annual Loss (AAL):
% trapz(X,Y)
AAL_ETC = trapz(prop_etc_interpolated,epGrid);
AAL_TC = trapz(prop_tc_interpolated,epGrid);

% Display results
disp(['  AAL Cool Season ($B) = ', num2str(AAL_ETC)]);
disp(['  AAL Warm Season ($B) = ', num2str(AAL_TC)]);

%% Compute Contribution Across Damage Curve

% Define a fine water level grid from min to max with 0.01m step
damage_min = min([prop_tc_interpolated, prop_etc_interpolated]);
damage_max = max([prop_tc_interpolated, prop_etc_interpolated]);
damage_common = 0.11:0.01:3;  % Fine grid of water levels


% Interpolate exceedance probabilities onto the common WL grid
startIdx = find(prop_tc_interpolated > 0, 1);  % first nonzero
EP_warm_interp = interp1(prop_tc_interpolated(startIdx:end), ...
                         epGrid(startIdx:end), ...
                         damage_common, 'linear', 0);

startIdx2 = find(prop_etc_interpolated > 0, 1);  % first nonzero
EP_cool_interp = interp1(prop_etc_interpolated(startIdx2:end), ...
                         epGrid(startIdx2:end), ...
                         damage_common, 'linear', 0);

%EP_warm_interp = interp1(prop_tc_interpolated, epGrid, damage_common, 'linear', 0); % Set missing values to 0
%EP_cool_interp = interp1(prop_etc_interpolated, epGrid, damage_common, 'linear', 0); % Set missing values to 0

% Compute total exceedance probability at each water level
EP_total = EP_warm_interp + EP_cool_interp;

% Compute relative contributions
Warm_contribution = (EP_warm_interp ./ EP_total) * 100; % Percentage warm
Cool_contribution = (EP_cool_interp ./ EP_total) * 100; % Percentage cool

% Handle NaN cases (where EP_total = 0)
Warm_contribution(isnan(Warm_contribution)) = 0;
Cool_contribution(isnan(Cool_contribution)) = 0;

% Display results
%disp('Damage | Warm Season EP | Cool Season EP | Total EP | Warm % | Cool %');
%disp([damage_common(:), EP_warm_interp(:), EP_cool_interp(:), EP_total(:), Warm_contribution(:), Cool_contribution(:)]);
figure; hold on;
plot(damage_common, Warm_contribution)
plot(damage_common, Cool_contribution)

%% Save output
saveName = char([site{siteIx} '_damage.mat']);

save(saveName, 'yrFinite', 'stormTideGrid', 'epGrid', 'ep_qjp_ann', ...
    'ST_qjp_ann', 'ep_qjp_int', 'ST_qjp_int', 'ep_qjp_ann_qtl', ...
    'ST_qjp_ann_qtl', 'ep_qjp_int_qtl', 'ST_qjp_int_qtl', 'quantiles',...
    'stormTideEI', 'epTotal', 'epTotal_qtl', 'stTotal', 'stTotal_qtl',...
    'prop_etc_interpolated','prop_tc_interpolated','prop_tot_interpolated',...
    'prop_etc_interpolated5','prop_tc_interpolated5','prop_tot_interpolated5',...
    'prop_etc_interpolated95','prop_tc_interpolated95','prop_tot_interpolated95',...
    'z','damage_curve','AAL_TC','AAL_ETC','damage_common','Warm_contribution','Cool_contribution'); 

