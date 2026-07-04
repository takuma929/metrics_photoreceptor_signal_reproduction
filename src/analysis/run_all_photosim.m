% First developed by ACS, modified by TM.
% run_all_photosim
% Run the complete photosim pipeline for one or more datasets and bit depths.
%
% For each dataset the reference database is (re)built once, then the
% requested display bit depths are swept: metrics are computed and a summary
% figure is plotted for each combination. A failure in any single run is
% reported and skipped rather than aborting the whole sweep.

clearvars;
close all;

% --- project paths (location-independent) ---
projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(fullfile(projectRoot, 'data'));
addpath(fullfile(projectRoot, 'results'));
dataDir = fullfile(projectRoot, 'data');
resDir  = fullfile(projectRoot, 'results');
figsDir = fullfile(projectRoot, 'figs');
if ~exist(figsDir, 'dir'); mkdir(figsDir); end


%% Environment setup


%% Sweep configuration
% datasets : 'Main' is the MAIN reference set (CIE daylight phases + the
%            401-set sources passing the broadcast-quality fidelity screen
%            Rf>=85 & Rg>=90; see build_main_illuminants.m).
%            'TM30' (original 401) and the SpectroSense folder are kept for
%            supplementary comparison and can be re-added here when refreshed.
% bitDepths: Inf for continuous weights, or 8/10/12 to include quantization.
datasets  = {'Main'};
bitDepths = [Inf, 12, 10, 8];

forceResimulate    = false;  % set true to ignore cached .mat files
runningFromWrapper = true;   % suppresses interactive prompts in sub-scripts

nRuns = numel(datasets) * numel(bitDepths);
fprintf('run_all_photosim: %d dataset(s) x %d bit depth(s) = %d run(s)\n', ...
    numel(datasets), numel(bitDepths), nRuns);

%% Main sweep
failures = {};
for d = 1:numel(datasets)
    realWorldDataset = datasets{d};
    fprintf('\n=== Dataset %d/%d: %s ===\n', d, numel(datasets), realWorldDataset);

    % (Re)build the reference database once per dataset.
    simulate_reference_database;

    for b = 1:numel(bitDepths)
        displayBitDepth = bitDepths(b);
        if isfinite(displayBitDepth)
            bitLabel = sprintf('%dbit', displayBitDepth);
        else
            bitLabel = 'Inf';
        end
        fprintf('\n--- Metrics: %s @ %s ---\n', realWorldDataset, bitLabel);

        try
            % run_metrics publishes metricsFile = the .mat it wrote/loaded.
            run_metrics;

            if exist('metricsFile', 'var') && exist(metricsFile, 'file') == 2
                % Metrics written successfully. Figures are drawn separately
                % by the plot_figure* scripts (via main.m).
            else
                warning('run_all_photosim:MissingMetrics', ...
                    'Metrics file for %s @ %s not found; skipping plot.', ...
                    realWorldDataset, bitLabel);
                failures{end+1} = sprintf('%s @ %s (no metrics file)', ...
                    realWorldDataset, bitLabel); %#ok<SAGROW>
            end
        catch err
            warning('run_all_photosim:RunFailed', ...
                'Run failed for %s @ %s: %s', realWorldDataset, bitLabel, err.message);
            failures{end+1} = sprintf('%s @ %s (%s)', ...
                realWorldDataset, bitLabel, err.message); %#ok<SAGROW>
        end
    end
end

%% Summary
% Recompute the run count here: nRuns is cleared by the sub-scripts'
% clearvars, whereas datasets/bitDepths are preserved via keepVars.
totalRuns = numel(datasets) * numel(bitDepths);
if isempty(failures)
    fprintf('\nAll %d run(s) completed successfully.\n', totalRuns);
else
    fprintf('\nCompleted with %d of %d run(s) failing:\n', numel(failures), totalRuns);
    fprintf('  - %s\n', failures{:});
end
