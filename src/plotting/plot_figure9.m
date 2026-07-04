% First developed by ACS, modified by TM.
% plot_figure9
% Figure 9 of the paper:
%   (a) PSRM vs bit depth for the Manchester VDU and Nugent-Zele system (TM30).
%   (b) PSRM vs display type under a uniform 1% tolerance vs per-receptor
%       Weber-fraction tolerances.
%
% All values are loaded/computed from results/ so the figure is fully
% reproducible from the data (previously these were hardcoded). Paths are
% resolved relative to this script so it runs from any working directory.

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

scriptDir  = fileparts(mfilename('fullpath'));
repoDir    = projectRoot;
resultsDir = fullfile(repoDir, 'results');
figsDir    = fullfile(repoDir, 'figs');
if ~exist(figsDir, 'dir'); mkdir(figsDir); end
figp = load_data().fig_parameters;   % provides figp

%% ------------------------------------------------------------------------
%  Figure 9(a) - PSRM vs bit depth for Manchester VDU and Nugent-Zele system
% -------------------------------------------------------------------------
bitFiles  = {'Inf','8bit','10bit','12bit'};
bitLabels = {'Inf.','8','10','12'};
psrmManchester = nan(1, numel(bitFiles));
psrmNugent     = nan(1, numel(bitFiles));
for i = 1:numel(bitFiles)
    S = load(fullfile(resultsDir, ...
        sprintf('photosimMetrics_ReproduceLMS_Main_%s.mat', bitFiles{i})), 'Man', 'NZ');
    psrmManchester(i) = S.Man.realworldReproductionMetric;
    psrmNugent(i)     = S.NZ.realworldReproductionMetric;
end
data = [psrmManchester; psrmNugent]';

colManchester = [223 178 86]/255; % golden
colNugent     = [43 183 172]/255; % teal

fig = figure; hold on; ax = gca;
b = bar(data, 'EdgeColor', 'none', 'BarWidth', 0.85);
b(1).FaceColor = colManchester;
b(2).FaceColor = colNugent;
alpha(b(1), 0.9);
alpha(b(2), 0.9);

ax.XTick = 1:numel(bitLabels);
ax.XTickLabel = bitLabels;
xlabel('Bit depth');
ylabel('PSRM [%]');
ax.YLim = [0 80];
yticks(0:20:80);
ax.XLim = [0.5 numel(bitLabels)+0.5];
legend({'Manchester VDU','Nugent-Zele system'}, 'Location', 'northwest', 'Box', 'off');

ax.FontName = 'Arial';
ax.FontSize = figp.fontsize;
ax.Color = [.97 .97 .97];
ax.XColor = 'k';
ax.YColor = 'k';
ax.LineWidth = 0.5;
ax.Units = 'centimeters';
legend off;

fig.Units = 'centimeters';
fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.Position = [10,10,figp.twocolumn/2*0.8,figp.twocolumn/4];
ax.Position = [0.8 0.8 6.2 3.4];
grid on; box off;

drawnow;
exportgraphics(fig, fullfile(figsDir, 'fig9a.pdf'), 'ContentType', 'vector');

%% ------------------------------------------------------------------------
%  Figure 9(b) - PSRM vs display type (1% vs per-receptor Weber tolerance)
% -------------------------------------------------------------------------
M = load(fullfile(resultsDir, 'photosimMetrics_ReproduceLMS_Main_Inf.mat'));
% PSRM exactly as get_psrm: relative error per receptor, count spectra whose
% every receptor is within tolerance. eps may be scalar or a 5x1 column.
psrmFun = @(d, eps) 100 * sum( sum( (abs(d.alphaReproduced - M.Sim.ss) ./ M.Sim.ss) > eps, 1) == 0 ) ...
    / size(M.Sim.ss, 2);
eps1 = 0.01;                          % uniform 1% tolerance
epsW = [0.09; 0.02; 0.02; 0.14; 0.01]; % Weber fractions, row order S,M,L,Rod,Mel

displayTypes = {'CRT','Dell LCD','Display++'};
dispVars     = {'CRT','LCD','DP'};
psrm_1pct  = nan(1,3);
psrm_Weber = nan(1,3);
for k = 1:numel(dispVars)
    d = M.(dispVars{k});
    psrm_1pct(k)  = psrmFun(d, eps1);
    psrm_Weber(k) = psrmFun(d, epsW);
end
data2 = [psrm_1pct; psrm_Weber]';

col1pct  = [255 161 123]/255;
colWeber = [132 198 225]/255;

fig = figure; hold on; ax = gca;
b2 = bar(data2, 'EdgeColor', 'none', 'BarWidth', 0.85);
b2(1).FaceColor = col1pct;
b2(2).FaceColor = colWeber;
alpha(b2(1), 0.9);
alpha(b2(2), 0.9);

ax.XTick = 1:3;
ax.XTickLabel = displayTypes;
xlabel('Display type');
ylabel('PSRM [%]');
ymaxB = ceil(max(data2(:)) + 0.5);   % headroom so the tallest bar is not clipped
ax.YLim = [0 ymaxB];
yticks(0:1:ymaxB);
ax.XLim = [0.5 3.5];
legend({'1% tolerance','Weber tolerance'}, 'Location', 'northwest', 'Box', 'off');

ax.FontName = 'Arial';
ax.FontSize = figp.fontsize;
ax.Color = [.97 .97 .97];
ax.XColor = 'k';
ax.YColor = 'k';
ax.LineWidth = 0.5;
ax.Units = 'centimeters';
legend off;

fig.Units = 'centimeters';
fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.Position = [10,10,figp.twocolumn/2*0.8,figp.twocolumn/4];
ax.Position = [0.8 0.8 6.2 3.4];
grid on; box off;

drawnow;
exportgraphics(fig, fullfile(figsDir, 'fig9b.pdf'), 'ContentType', 'vector');

%% report values to console for cross-checking against the manuscript
fprintf('\nFigure 9(a) PSRM%% [Inf 8 10 12]:\n');
fprintf('  Manchester : %s\n', num2str(psrmManchester, '%6.1f'));
fprintf('  Nugent-Zele: %s\n', num2str(psrmNugent, '%6.1f'));
fprintf('Figure 9(b) PSRM%% [CRT LCD DP]:\n');
fprintf('  1%% tol  : %s\n', num2str(psrm_1pct, '%6.2f'));
fprintf('  Weber tol: %s\n', num2str(psrm_Weber, '%6.2f'));

