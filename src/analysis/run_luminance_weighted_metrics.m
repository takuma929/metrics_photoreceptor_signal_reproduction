% First developed by ACS, modified by TM.
% run_luminance_weighted_metrics.m
% C5 (Reviewer 1, comment 5): does weighting spectra by luminance change the
% metrics? Compares equal-weight PSRM/PSDM with luminance-weighted versions
% (weight = Y / max(Y)). If the two are close, dark and bright spectra are
% effectively equally important and the equal-weight design is justified.
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


M = load(fullfile(resDir,'photosimMetrics_ReproduceLMS_Main_Inf.mat'));
ref = M.Sim.ss;                      % 5 x n  real-world signals
Y   = M.Sim.xyY(3,:);                % photopic luminance per spectrum
w   = Y ./ max(Y);                   % luminance weight, max -> 1
eps = 0.01;
disps = {'CRT','LCD','DP','nb5p','bb5p','Man','MPHDR','NZ'};

fprintf('Luminance weight: min=%.3g median=%.3g max=%.3g\n', min(w), median(w), max(w));
fprintf('\n%-6s | %-16s | %-16s\n','disp','PSRM  eq / lum','PSDM  eq / lum');
PSRM_eq=nan(1,8); PSRM_lum=nan(1,8); PSDM_eq=nan(1,8); PSDM_lum=nan(1,8);
for j = 1:numel(disps)
    d = M.(disps{j});
    A = d.alphaReproduced;
    err = abs(A - ref) ./ ref;
    repro = all(err <= eps, 1);                 % 1 x n reproduced flag
    PSRM_eq(j)  = 100 * mean(repro);
    PSRM_lum(j) = 100 * sum(w .* repro) / sum(w);

    % overall PSDM = mean over receptors of mean|distortion| (nonzero ref)
    dist = abs(A - ref) ./ ref * 100;           % 5 x n
    nz = ref ~= 0;
    perRecEq = nan(5,1); perRecLum = nan(5,1);
    for k = 1:5
        m = nz(k,:);
        perRecEq(k)  = mean(dist(k,m));
        perRecLum(k) = sum(w(m).*dist(k,m)) / sum(w(m));
    end
    PSDM_eq(j)  = mean(perRecEq,'omitnan');
    PSDM_lum(j) = mean(perRecLum,'omitnan');
    fprintf('%-6s | %6.2f / %6.2f | %6.2f / %6.2f\n', disps{j}, PSRM_eq(j), PSRM_lum(j), PSDM_eq(j), PSDM_lum(j));
end
save(fullfile(resDir,'luminanceWeightedMetrics.mat'),'PSRM_eq','PSRM_lum','PSDM_eq','PSDM_lum','disps','w');
fprintf('\nMax |PSRM eq-lum| diff = %.2f ; Max |PSDM eq-lum| diff = %.2f\n', max(abs(PSRM_eq-PSRM_lum)), max(abs(PSDM_eq-PSDM_lum)));
