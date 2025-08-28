%% MATLAB Code for Creating Plots from
% Apoznanski et al., 2025
% Authors: Hannah Baranes and Diana Apoznanski

% Analysis notes: 
    % Run each section in order, the scetions depend on variables from each
    % other.
    
    % Output from Baranes et al. (2020)'s qn_ssjpm_v4.m (TheBattery_qn_ssjpm.mat) 
    % and calc_skew_split_seasons_data_gaps.m (TheBattery_m_p_skewSurge_splitSeason.mat) 
    % is read into this script for The Battery tide gauge. 

    % Baranes et al. (2020) (TheBattery_qn_ssjpm.mat) output notes:
    % epTotal_qtl --> # exceedances (inverse RP)
    % stTotal_qtl --> storm tide
    % _ann --> separate curve for each year (1000 curves per year)
    % _int --> integrated, no separate calculations per year (1000 curves total, qnSSJPM from lit)
    % total --> combined summer and winter
    % qtl --> only qtls not 1000 curves

    % For the economic deep dive at The Battery, we use the data and damage curve
    % (damage_curve_manhattan_property_area_elevation.mat) 
    % from Rasmussen et al. (2020)'s supplemental section A6. 
   

% Plots created:
    % 1. qn-SSJPM curves (Cool-season, warm-season, and total year) 

    
clear all; close all; 

%% 1. Joint probability curves

% Load site
siteIx = 1; 
site{1} = 'TheBattery'; 
qnSSJPM_file = char([site{siteIx} '_qn_ssjpm.mat']); load(qnSSJPM_file); 
a = {'etc' 'tc'};

% Plot - compare total to seasonal 
figure; hold on; 

% Cool- and warm- seasons
col{1} = 'b'; 
col{2} = 'r'; 
line{1}= '-'; line{2}='--';
for i=1:2    
    ix = isfinite(ST_qjp_int_qtl.(a{i})(2,:)); 
    fill([ST_qjp_int_qtl.(a{i})(2,ix) fliplr(ST_qjp_int_qtl.(a{i})(3,ix))], [epGrid(ix) fliplr(epGrid(ix))], col{i}, 'EdgeColor', 'none', 'FaceAlpha', 0.3)
    hd(i) = plot(ST_qjp_int_qtl.(a{i})(1,:), epGrid, 'Color', col{i}, 'LineWidth', 1.4,'LineStyle', line{i}); 
end

% Total 
ix = isfinite(stTotal_qtl(2,:)); 
fill([stTotal_qtl(2,ix) fliplr(stTotal_qtl(3,ix))], [epGrid(ix) fliplr(epGrid(ix))], 'k', 'EdgeColor', 'none', 'FaceAlpha', 0.3)
hd(3) = plot(stTotal_qtl(1,:), epGrid, 'k', 'LineWidth', 1.8); 

%legend(hd, 'ETC', 'TC', 'Total')
title(site)
xlabel('Storm Tide'); ylabel('Exceedances/yr'); 
set(gca, 'yscale', 'log'); 
ylim([(1/500) 1]); 
grid on 

%add emperical
skew_file = char([site{siteIx} '_m_p_skewSurge_splitSeason.mat']); load(skew_file); 

nYrs=struct;
nYrs.etc = sum(isfinite(m.etc.yr)); 
nYrs.tc = sum(isfinite(m.tc.yr));
if nYrs.etc > nYrs.tc
    nYrs.tot = nYrs.etc;
else 
    nYrs.tot = nYrs.tc;
end

% combine all high waters 
HWc_tot= [m.etc.HWc m.tc.HWc];
HWc_etc =  m.etc.HWc; 
HWc_tc =  m.tc.HWc;
% sort high waters
HWc_srt_tot= sort(HWc_tot, 'descend');
HWc_srt_tc = sort(HWc_tc, 'descend');
HWc_srt_etc = sort(HWc_etc, 'descend');
% rank high waters
rank_tot = 1:length(HWc_srt_tot);
rank_tc = 1:length(HWc_srt_tc); 
rank_etc = 1:length(HWc_srt_etc);
% fit emperical events to exceedance curve
empExcTot_tot = (rank_tc / (nYrs.tot));
empExcTot_tc = (rank_tc / (nYrs.tc));
empExcTot_etc = (rank_etc / (nYrs.etc));
ix_tot = find(empExcTot_tot <= 1); 
ix_tc = find(empExcTot_tc <= 1); 
ix_etc = find(empExcTot_etc <= 1);

% Plot empirical data and store handles for legend
h_emp_tc = plot(HWc_srt_tc(ix_tc), empExcTot_tc(ix_tc), 'r+','MarkerSize',10);
h_emp_etc = plot(HWc_srt_etc(ix_etc), empExcTot_etc(ix_etc), 'bo','MarkerSize',10);
h_emp_tot = plot(HWc_srt_tot(ix_tot), empExcTot_tot(ix_tot), 'kv','MarkerSize',10);

% Update legend to include empirical data
legend([hd, h_emp_tc, h_emp_etc, h_emp_tot], 'ETC', 'TC', 'Total', 'Empirical TC', 'Empirical ETC', 'Empirical Total')

