% First developed by ACS, modified by TM.
% compute_illuminant_rf_rg.m  (C3, Reviewer 1 comment 3)
%
% Compute ANSI/IES TM-30-18 Rf, Rg (and CCT, Duv, Rcs,h1) for each of the 401
% illuminants in data/401Illuminants.csv using the pure-MATLAB compute_tm30
% (functions/tm30), which reproduces the colour-science implementation
% (FL2 Rf=70.12, D65/A Rf=Rg=100). Writes results/illuminant_RfRg.csv with one
% row per illuminant so the high-fidelity subset (Rf>=85 & Rg>=90) can be
% selected and re-run through the photoSim metrics.
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


D  = load_tm30_data();
wl = D.wl;

src = load_data().illuminants_401;
assert(max(abs(src(:,1)-wl)) < 1e-9, '401 grid must be 380:5:780.');
illum = src(:,2:end);
nIll = size(illum,2);
fprintf('Loaded 401Illuminants.csv: %d illuminants on %d wavelengths (%d-%d nm)\n', ...
        nIll, numel(wl), wl(1), wl(end));

rows = nan(nIll, 6);   % index CCT Rf Rg Duv Rcs_h1
for j = 1:nIll
    v = illum(:,j);
    if ~any(v > 0), rows(j,:) = [j nan nan nan nan nan]; continue; end
    r = compute_tm30(v, wl, D);
    rows(j,:) = [j r.CCT r.Rf r.Rg r.Duv r.Rcs(1)];
    if mod(j,100)==0, fprintf('  ...%d/%d\n', j, nIll); end
end

outFile = fullfile(resDir, 'illuminant_RfRg.csv');
fid = fopen(outFile, 'w');
fprintf(fid, 'index,CCT,Rf,Rg,Duv,Rcs_h1\n');
fprintf(fid, '%d,%.2f,%.4f,%.4f,%.6f,%.4f\n', rows.');
fclose(fid);
fprintf('Wrote %s\n', outFile);

ok  = isfinite(rows(:,3)) & isfinite(rows(:,4));
sel = ok & rows(:,3)>=85 & rows(:,4)>=90;
fprintf('\nRf range [%.1f, %.1f], Rg range [%.1f, %.1f]\n', ...
        min(rows(ok,3)), max(rows(ok,3)), min(rows(ok,4)), max(rows(ok,4)));
fprintf('Illuminants with Rf>=85 AND Rg>=90: %d / %d valid\n', sum(sel), sum(ok));
