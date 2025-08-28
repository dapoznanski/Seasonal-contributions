% Plots for Economic Analysis for the Battery site from Apoznanski et al. 2025
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
% 1. TheBattery_damage.mat (the output of battery_damage.m by Diana Apoznanski from Apoznanski et al. (2025)).

%% Input data
% Load damage
clear
close all;
load('TheBattery_damage.mat');

% Load site
siteIx = 1; 
site{1} = 'TheBattery'; 
qnSSJPM_file = char([site{siteIx} '_qn_ssjpm.mat']); load(qnSSJPM_file); 
a = {'etc' 'tc'};
%% Plot economic analysis 2x2
figure;
% Get handles for all subplots
h1 = subplot(2,2,1);
h2 = subplot(2,2,2);  % Damage curve
h3 = subplot(2,2,3);  % Exceedance vs damage
h4 = subplot(2,2,4);  % Relative contribution


% ==== First subplot: Original qn-SSJPM curve for The Battery ====
subplot(2,2,1);

hold on;

% Summer and winter
col{1} = 'b'; 
col{2} = 'r'; 
line{1}= '-'; line{2}='--';
for i=1:2    
    ix = isfinite(ST_qjp_int_qtl.(a{i})(2,:)); 
    fill([ST_qjp_int_qtl.(a{i})(2,ix) fliplr(ST_qjp_int_qtl.(a{i})(3,ix))], [epGrid(ix) fliplr(epGrid(ix))], col{i}, 'EdgeColor', 'none', 'FaceAlpha', 0.3)
    hd(i) = plot(ST_qjp_int_qtl.(a{i})(1,:), epGrid, 'Color', col{i}, 'LineWidth', 1.4,'LineStyle', line{i}); 
end
ix = isfinite(stTotal_qtl(2,:)); 
fill([stTotal_qtl(2,ix) fliplr(stTotal_qtl(3,ix))], [epGrid(ix) fliplr(epGrid(ix))], 'k', 'EdgeColor', 'none', 'FaceAlpha', 0.3)
hd(3) = plot(stTotal_qtl(1,:), epGrid, 'k', 'LineWidth', 1.8); 

% Total 
legend(hd, 'Cool Season', 'Warm Season', 'Total')%,'FontSize',18
title('The Battery (7) Joint Probability','FontSize',14)
xlabel('Storm Tide (m above MSL)','FontSize',14); 
ylabel('Exceedances/yr','FontSize',14); 
set(gca, 'yscale', 'log'); 
ylim([(1/500) 1]); 
xlim([0 3]);
grid on;
hold off;
% ==== Second subplot: Flood Damage Curve for Manhattan ====
subplot(2,2,3);
plot(z + 0.758, damage_curve, 'k-', 'LineWidth', 2); hold on; %D_billion; add 0.758 to damage curve to present in MSL
xlabel('Storm Tide (m above MSL)','FontSize',14);
ylabel('Total Damage (Billion USD)','FontSize',14);
title('Manhattan Flood Damage Curve (Rasmussen et al., 2020)', 'FontSize',14);
xlim([0 3]);
grid on;

% ==== Third subplot: Exceedances vs. Accumulated Property Damage ====
subplot(2,2,2);
ax1 = gca; % Store handle for bottom x-axis
hold on;
h1 = plot(prop_etc_interpolated, epGrid, 'b-', 'LineWidth', 1.5, 'DisplayName', 'ETC Damage');
h2 = plot(prop_tc_interpolated, epGrid, 'r--', 'LineWidth', 1.5, 'DisplayName', 'TC Damage');
h3 = plot(prop_tot_interpolated, epGrid, 'k-', 'LineWidth', 2, 'DisplayName', 'Total Damage');
fill([prop_etc_interpolated5 fliplr(prop_etc_interpolated95)],[epGrid fliplr(epGrid)],'b', 'EdgeColor', 'none', 'FaceAlpha', 0.3);
fill([prop_tc_interpolated5 fliplr(prop_tc_interpolated95)],[epGrid fliplr(epGrid)],'r', 'EdgeColor', 'none', 'FaceAlpha', 0.3);

title('Exceedances vs Total Property Damage','FontSize',14);
ylabel('Exceedances/yr','FontSize',14);
xlabel('Total Damage (Billion USD)','FontSize',14);
set(gca, 'yscale', 'log'); % Log scale for exceedances
xlim([0 3]);
grid on;

% Add top x-axis for water levels
ax2 = axes('Position', ax1.Position, 'XAxisLocation', 'top', 'Color', 'none');
ax2.XLim = ax1.XLim;
ax2.XTick = ax1.XTick;
ax2.XTickLabel = round(interp1(prop_tot_interpolated(100:end), ST_qjp_int_qtl.etc(1,100:end), ax1.XTick, 'linear', 'extrap'), 1);
ax2.YColor = 'none';
xlabel(ax2, 'Storm Tide (m above MSL)','FontSize',14);

% ==== Fourth subplot: Relative Contribution ====
subplot(2,2,4);
ax3 = gca;
hold on;
h4 = plot(damage_common, Warm_contribution, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Warm Season Contribution');
h5 = plot(damage_common, Cool_contribution, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Cool Season Contribution');
ylim([0 100]);
xlim([1 3]);
title('Relative Contribution to Property Damage','FontSize',14);
xlabel('Total Damage (Billion USD)','FontSize',14);
ylabel('Relative Contribution (%)','FontSize',14);
legend([h5 h4], 'Cool Season', 'Warm Season', 'Total')
grid on;

% ==== Link Axes and Legends ====
linkaxes([ax1, ax3], 'x'); % Synchronize x-axes
legend(ax1, [h1, h2, h3, h4], {'Cool Season', 'Warm Season', 'Total Damage'}, 'Location', 'northeast');

% try print with -loose option
print('-depsc2','-r600',strcat('test_loose','.eps'),'-loose');
