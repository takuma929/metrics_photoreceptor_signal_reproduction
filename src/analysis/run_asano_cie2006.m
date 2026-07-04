% First developed by ACS, modified by TM.
% ========================================================================
% run_asano_cie2006.m
%

clearvars; close all; clc;

% --- project paths (location-independent) ---
projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(fullfile(projectRoot, 'data'));
addpath(fullfile(projectRoot, 'results'));
dataDir = fullfile(projectRoot, 'data');
resDir  = fullfile(projectRoot, 'results');
figsDir = fullfile(projectRoot, 'figs');
if ~exist(figsDir, 'dir'); mkdir(figsDir); end


sdList   = [5 10 20 40];          % primary SD sweep (nm)
peakBase = [450 540 610];         % fixed peaks for B,G,R (nm)

TOTAL_OBS = 10000; % total number of observers
N2  = floor(TOTAL_OBS/2); % total number of observers
N10 = TOTAL_OBS - N2; % total number of observers

ASANO = struct();
ASANO.seed      = 0;
ASANO.age_range = [18 70];
ASANO.normalize = 'max';

rng(0)

%% ============================================================
%  Generate observer family (Asano CIE2006)
%% ============================================================
fprintf('Generating Asano CIE2006 observer family...\n');
% The CIE2006/Asano prereceptoral tables are read from the consolidated data
% store (data.cie2006_*) inside generate_cone_fund_family_asano_cie2006.

coneFam = generate_cone_fund_family_asano_cie2006( ...
    'N2',         N2, ...
    'N10',        N10, ...
    'seed',       ASANO.seed, ...
    'age_range',  ASANO.age_range, ...
    'normalize',  ASANO.normalize ...
);

out.wls      = coneFam.wl_out(:);                         % SOURCE OF TRUTH
out.nW       = numel(out.wls);
out.T_indiv  = permute(coneFam.fund, [3 2 1]);            % 3 x nW x nObs
out.obs_meta = coneFam.meta;

wls      = coneFam.wl_out(:);                         % SOURCE OF TRUTH
nW       = numel(out.wls);
T_indiv  = permute(coneFam.fund, [3 2 1]);            % 3 x nW x nObs
obs_meta = coneFam.meta;


out.wls = wls;
out.nW = nW;
out.T_indiv = T_indiv;
out.obs_meta = obs_meta;
out.N2 = N2;
out.N10 = N10;
out.nObs = size(out.T_indiv,3);

fprintf('Using nObs=%d (N2=%d, N10=%d), nW=%d spectral channels\n', out.nObs, out.N2, out.N10, out.nW);

% store the observer family in the consolidated data store
data = load_data();
data.asano_observers = out;
save(fullfile(dataDir,'data.mat'), 'data', '-v7.3');
clear load_data                                     % drop the stale cached store

%% ============================================================
%  Figure: Plot individual cone fundamentals
%% ============================================================
T_indiv = permute(T_indiv,[3 2 1]);

cone_fund = T_indiv;

Nobs = size(cone_fund,1);

cf = cone_fund;
mx = max(cf, [], 2);
mx(mx<=0) = eps;
cfN = cf ./ mx;

cfMed = squeeze(median(cfN, 1));      % [nW x 3]

colL = [0.85 0.10 0.10];
colM = [0.10 0.60 0.10];
colS = [0.10 0.30 0.85];

fig = figure('Color','w'); ax = axes(fig); hold(ax,'on');

step = 10; idx = 1:step:Nobs;
plot(ax, wls, squeeze(cfN(idx,:,1))', 'LineWidth', 0.15, 'Color', colL);
plot(ax, wls, squeeze(cfN(idx,:,2))', 'LineWidth', 0.15, 'Color', colM);
plot(ax, wls, squeeze(cfN(idx,:,3))', 'LineWidth', 0.15, 'Color', colS);

plot(ax, wls, cfMed(:,1), '-', 'LineWidth', 0.8, 'Color', colL);
plot(ax, wls, cfMed(:,2), '-', 'LineWidth', 0.8, 'Color', colM);
plot(ax, wls, cfMed(:,3), '-', 'LineWidth', 0.8, 'Color', colS);

xlabel(ax,'Wavelength (nm)','FontWeight','Bold');
ylabel(ax,'Normalized sensitivity','FontWeight','Bold');

xlim([390-10 780+10]); ylim([0 1.05]);

fig.Units          = 'centimeters';
fig.Color          = 'w';
fig.InvertHardcopy = 'off';

ax.FontName  = 'Arial';
ax.FontSize  = 8;
ax.XColor    = 'k';
ax.YColor    = 'k';
ax.LineWidth = 0.5;
ax.Units     = 'centimeters';

fig.Position = [10,10,17.8/3*1.2,17.8/3*1.2];
ax.Position  = [0.90 0.74, 17.8/3, 17.8/3];

xticks([400 500 600 700 780]);
yticks([0 0.5 1.0]);
ax.XTickLabel = {'400','500','600','700','780'};
ax.YTickLabel = {'0.0','0.5','1.0'};

grid(ax,'off'); box(ax,'off');
ax.Color = ones(1,3)*0.97;

exportgraphics(fig, fullfile(figsDir,'cone_fundamentals_family.png'), ...
    'ContentType','image','Resolution',300);
