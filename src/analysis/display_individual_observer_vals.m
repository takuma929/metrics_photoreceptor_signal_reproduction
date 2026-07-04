% First developed by ACS, modified by TM.
% display_individual_observer_vals.m
% C2 (Reviewer 1, comment 2): display the individual-observer PSRM and PSDM
% results from the Asano CIE2006 model.
%
% Variability is reported as mean +/- 1 SD across ALL observers (the 2-deg and
% 10-deg Asano samples are pooled; they behave the same). The family mean is
% near the standard observer by construction (Asano samples observers around
% the population average), so the informative quantity is the inter-observer SD.
%
%   - PSRM: fraction of spectra reproduced (all eight displays).
%   - PSDM: median rod / melanopsin distortion for the three-primary displays
%           (PSDM is ~0 for in-gamut five-primary displays, so not reported).
%
% Loads results/individualObserverMetrics.mat (from run_individual_observer_metrics.m).

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


S = load(fullfile(resDir,'individualObserverMetrics.mat'));
nObs = size(S.PSRM,1);

fprintf('=== C2 individual-observer metrics (Asano), N = %d observers (2deg & 10deg pooled) ===\n\n', nObs);

fprintf('PSRM (%%): fraction of spectra reproduced\n');
fprintf('%-6s | %8s | %s\n','disp','stdObs','mean +/- 1SD');
disp(repmat('-',1,40));
for j = 1:numel(S.disps)
    a = S.PSRM(:,j);
    fprintf('%-6s | %8.2f | %6.2f +/- %4.2f\n', S.disps{j}, S.PSRM_std(j), mean(a), std(a));
end

fprintf('\nPSDM (%%): median rod / melanopsin distortion (three-primary displays)\n');
fprintf('%-4s | %-22s | %-22s\n','disp','rod  (std / mean+/-SD)','mel  (std / mean+/-SD)');
disp(repmat('-',1,54));
for j = 1:numel(S.threeP)
    r = S.rodMed(:,j); m = S.melMed(:,j);
    fprintf('%-4s | %6.2f / %6.2f +/- %4.2f | %6.2f / %6.2f +/- %4.2f\n', S.threeP{j}, ...
        S.rodMed_std(j), mean(r), std(r), S.melMed_std(j), mean(m), std(m));
end

fprintf(['\nPSRM: optimised five-primary (nb5p, bb5p) and three-primary displays\n' ...
         'have small SD; Manchester / MPHDR intermediate; Nugent-Zele largest.\n' ...
         'PSDM: rod and melanopsin distortion of the three-primary displays is\n' ...
         'stable across observers (small SD), confirming the reported distortions\n' ...
         'are not an artefact of the standard-observer choice.\n']);
