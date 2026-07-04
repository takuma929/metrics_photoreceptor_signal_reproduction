% First developed by ACS, modified by TM.
% run_individual_observer_metrics.m
% C2 (Reviewer 1, comment 2): propagate the Asano (2016) CIE2006 individual cone
% fundamentals through PSRM/PSDM to quantify how stable the metrics are across
% observers. Only L/M/S cones vary per observer; rod & melanopsin use the
% standard CIE S026 functions.
%
% PSRM uses the SAME definition as the manuscript (get_psrm): a spectrum is
% reproduced if the non-negative least-squares (lsqnonneg) display solution
% matches the target within 1% on all five receptors. For speed the exact solve
% is used first and lsqnonneg is only run on the columns whose exact weights have
% a negative component (the gamut-boundary cases).

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



NPER = 500;        % observers sampled per field size (2-deg and 10-deg). Total = 2*NPER.
eps  = 0.01;

%% 1. Asano individual cone fundamentals
out = load_data().asano_observers;
Tind  = out.T_indiv;                 % 3 x 79 x nObs, dim1 = L, M, S
field = out.obs_meta.field_deg;
idx2  = find(field==2,  NPER, 'first');
idx10 = find(field==10, NPER, 'first');
idxObs = [idx2; idx10];
grp = [2*ones(numel(idx2),1); 10*ones(numel(idx10),1)];

%% 2. real-world spectra (Main set, 5 nm) and standard sensitivities
simRad = get_simulated_spectra('Main');
if size(simRad,1)==391, simRad = simRad(1:5:end,:); end
ss = get_cies026; T = ss(:,11:end); T(isnan(T))=0; T5 = T(:,1:5:end);
R_std = T5(4,:); I_std = T5(5,:);

%% 3. displays (precompute 5 nm primaries)
DB = load(fullfile(resDir,'photosimReferenceDatabase_Main.mat'));
threeP = {'CRT','LCD','DP'}; fiveP = {'nb5p','bb5p','Man','MPHDR','NZ'}; disps = [threeP fiveP];
spd3  = cellfun(@(nm) DB.(nm).spd(1:5:end,:), threeP, 'uni', 0);
% Five-/multi-primary research displays. Most sit on the full 390:780 grid
% (79 samples at 5 nm); the Manchester VDU spd is only defined over 390:685
% (60 samples), exactly the T_cies026_M = ss(:,11:310) grid used in the main
% analysis (get_distortions). Because that grid shares the 390 nm origin, no
% padding is needed: obsMetrics integrates Man against the first 60 columns of
% the observer fundamentals, To(:,1:ng), which reproduces the stored Man PSRM.
spd5p = cellfun(@(nm) DB.(nm).spd(1:5:end,:), fiveP,  'uni', 0);

%% standard-observer baseline (same method) - validates against stored metrics
[PSRM_std, rodMed_std, melMed_std] = obsMetrics(T5, simRad, spd3, spd5p, eps);

%% 5. loop observers
nO = numel(idxObs);
PSRM = nan(nO,numel(disps)); rodMed = nan(nO,numel(threeP)); melMed = nan(nO,numel(threeP));
tic;
for ii = 1:nO
    o = idxObs(ii);
    To = [squeeze(Tind(3,:,o)); squeeze(Tind(2,:,o)); squeeze(Tind(1,:,o)); R_std; I_std]; % rows S,M,L,R,I
    [PSRM(ii,:), rodMed(ii,:), melMed(ii,:)] = obsMetrics(To, simRad, spd3, spd5p, eps);
    if mod(ii,50)==0, fprintf('  ...%d/%d (%.0fs)\n', ii, nO, toc); end
end
fprintf('Computed %d observers in %.1f s\n', nO, toc);

%% 6. report
is2 = grp==2; is10 = grp==10;
std0 = load(fullfile(resDir,'photosimMetrics_ReproduceLMS_Main_Inf.mat'), disps{:});
% Inter-observer variability reported as mean +/- 1 SD across ALL observers
% (the 2-deg and 10-deg samples are pooled; they behave essentially the same).
fprintf('\n=== PSRM (%%): mean +/- 1 SD across all %d observers (2deg & 10deg pooled) ===\n', 2*NPER);
fprintf('%-6s %8s %8s   %s\n','disp','getDist','std*','mean +/- 1SD');
for j=1:numel(disps)
    a = PSRM(:,j);
    fprintf('%-6s %8.2f %8.2f   %6.2f +/- %4.2f\n', disps{j}, ...
        std0.(disps{j}).realworldReproductionMetric, PSRM_std(j), mean(a), std(a));
end
fprintf('\n=== median PSDM (%%): mean +/- 1 SD across all %d observers (3-primary displays) ===\n', 2*NPER);
fprintf('%-4s | %22s | %22s\n','disp','rod median (std / mean+/-SD)','mel median (std / mean+/-SD)');
for j=1:numel(threeP)
    fprintf('%-4s | %6.2f / %6.2f +/- %4.2f | %6.2f / %6.2f +/- %4.2f\n', threeP{j}, ...
        rodMed_std(j), mean(rodMed(:,j)), std(rodMed(:,j)), ...
        melMed_std(j), mean(melMed(:,j)), std(melMed(:,j)));
end
save(fullfile(resDir,'individualObserverMetrics.mat'),'PSRM','rodMed','melMed','grp','idxObs', ...
    'disps','threeP','fiveP','PSRM_std','rodMed_std','melMed_std','NPER');
fprintf('\nSaved results/individualObserverMetrics.mat (NPER=%d)\n', NPER);

%% ---- local functions ----
function [psrmRow, rodMedRow, melMedRow] = obsMetrics(To, simRad, spd3, spd5p, eps)
    Ao = To * simRad;
    n3 = numel(spd3); n5 = numel(spd5p);
    psrmRow = nan(1, n3+n5); rodMedRow = nan(1,n3); melMedRow = nan(1,n3);
    for j = 1:n3
        % PSDM (manuscript definition, get_distortions + get_psdm): match the three
        % cones (rows 1:3 = S,M,L) by non-negative least squares, then measure the
        % signed per-receptor distortion of the reproduced signal over ALL spectra.
        lms = To*spd3{j};                              % 5x3
        W = lms(1:3,:)\Ao(1:3,:);                       % exact cone match where in gamut
        neg = find(any(W<0,1));                         % out-of-cone-gamut -> clamp (lsqnonneg)
        for c = neg(:)', W(:,c) = lsqnonneg(lms(1:3,:), Ao(1:3,c)); end
        Arep = lms*W; err = abs(Arep-Ao)./Ao;           % 5xN relative error
        psrmRow(j) = 100*mean(all(err<=eps,1));         % PSRM (all 5 within tol) - matches get_distortions
        dist = 100*(Arep-Ao)./Ao;                       % per-receptor PSDM_ki, all spectra
        rodMedRow(j) = median(dist(4,:),'omitnan');     % median rod distortion (PSDM_R)
        melMedRow(j) = median(dist(5,:),'omitnan');     % median melanopsin distortion (PSDM_I)
    end
    for j = 1:n5
        spd = spd5p{j}; ng = size(spd,1);   % ng=79 (full grid) or 60 (Manchester, 390:685)
        lms = To(:,1:ng)*spd;
        W = lms\Ao; repro = all(W>=0,1); neg = find(~repro);
        for c = neg(:)'
            w = lsqnonneg(lms, Ao(:,c)); a = lms*w;
            if all(abs(a-Ao(:,c))./Ao(:,c) <= eps), repro(c) = true; end
        end
        psrmRow(n3+j) = 100*mean(repro);
    end
end
