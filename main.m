% First developed by ACS, modified by TM.
function main(REBUILD_METRICS, REBUILD_SUPPORTING)
% MAIN  One-click regeneration of the PhotoSim results and all paper figures.
%
%   >> main                 rebuild everything, then redraw every figure
%   >> main(false)          reuse existing results/*.mat, only redraw figures
%   >> main(true, true)     also rerun the supporting (Table) analyses
%
%   Stages
%     (1) run_all_photosim - reference databases + metrics for the main
%         reference set at every display bit depth,
%     (2) supporting analyses that feed the Table values (optional, slow), and
%     (3) redraw every figure in the paper into  figs/.
%
%   Requirements
%     - MATLAB (developed with R2025b)
%     - Psychtoolbox on the path (provides SplineSpd / GenerateCIEDay etc.)
%     - data/data.mat  (bundled; the single consolidated data store)
%
%   Notes
%     Each analysis/plotting script clears the base workspace and re-derives
%     its own paths, so they are launched with evalin('base', ...) to keep
%     this wrapper's own loop variables isolated from their `clear all`.

% ---------------------------------------------------------------- configuration
if nargin < 1 || isempty(REBUILD_METRICS),    REBUILD_METRICS    = true;  end
if nargin < 2 || isempty(REBUILD_SUPPORTING), REBUILD_SUPPORTING = false; end

% ------------------------------------------------------------------------- paths
projectRoot = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(fullfile(projectRoot, 'results'));
figsDir = fullfile(projectRoot, 'figs');
if ~exist(figsDir, 'dir'); mkdir(figsDir); end

% --------------------------------------------------------------- 1. metrics
if REBUILD_METRICS
    fprintf('\n=== [1/3] Rebuilding reference databases and metrics ===\n');
    evalin('base', 'run_all_photosim');
end

% ------------------------------------------------- 2. supporting analyses
if REBUILD_SUPPORTING
    fprintf('\n=== [2/3] Supporting analyses (Table values) ===\n');
    evalin('base', 'run_individual_observer_metrics');   % Tables 2 & 3
    evalin('base', 'run_luminance_weighted_metrics');    % Section 3.4.5
end

% ---------------------------------------------------------------- 3. figures
fprintf('\n=== [3/3] Drawing all paper figures into figs/ ===\n');
figures = { ...
    'plot_figure1', ...        % spectral sensitivities & example signals
    'plot_figure2', ...        % equal-luminance MacLeod-Boynton locus
    'plot_figure3', ...        % display primaries
    'plot_figure4', ...        % chromaticity reproduction & PSRM
    'plot_figure5and6', ...    % PSDM (rod & melanopsin distortion)
    'plot_figure7and8', ...    % equal-luminance excitation diagrams
    'plot_figure9'};           % bit depth & tolerance

for i = 1:numel(figures)
    fprintf('  -> %s\n', figures{i});
    evalin('base', figures{i});
end

fprintf('\nDone. Figures written to %s\n', figsDir);
end
