% First developed by ACS, modified by TM.
% build_main_illuminants.m  (C3, Reviewer 1 comment 3)
%
% Build a *main* reference illuminant set to replace the TM-30
% 401-illuminant set (whose fidelity ranges 0-100 and includes physically
% implausible / extreme sources). The new set contains only:
%   (1) CIE daylight phases across a range of correlated colour temperatures
%       (generated from the CIE daylight model), and
%   (2) the illuminants already present in the original 401-illuminant set
%       that pass a broadcast-quality fidelity screen: ANSI/IES TM-30-18
%       Rf >= 85 AND Rg >= 90. (The red-bin local chroma shift Rcs,h1 of the
%       retained sources already falls within [-9.7, +11.3]%, so no separate
%       red-saturation criterion is needed.) These are
%       extracted from the 401 set, not synthesised.
%
% Blackbody radiators are deliberately excluded (author decision).
%
% Fidelity is evaluated with the pure-MATLAB compute_tm30 (functions/tm30),
% which reproduces the colour-science ANSI/IES TM-30-18 implementation
% (FL2 Rf=70.12, D65/A Rf=Rg=100; identical high-fidelity screen on the 401).
%
% Outputs (wl in col 1, one illuminant per column, 380:5:780):
%   data.mat -> data.main_illuminants   [81 x (1+183)]
%   results/mainIlluminants_meta.csv    index,type,CCT,Duv,Rf,Rg,Rcs_h1
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


% ------------------------------ configuration ------------------------------
DAYLIGHT_CCTS = 4000:250:20000;      % CIE daylight phases (Rf ~ 96-100)
RF_MIN = 85;  RG_MIN = 90;
OUT_META = fullfile(resDir,  'mainIlluminants_meta.csv');
% ---------------------------------------------------------------------------

data = load_data();
D  = load_tm30_data();
wl = D.wl;

% --- (1) CIE daylight phases ---
fprintf('Building CIE daylight phases (%d-%d K)...\n', DAYLIGHT_CCTS(1), DAYLIGHT_CCTS(end));
dCols = zeros(numel(wl), numel(DAYLIGHT_CCTS));
dMeta = zeros(numel(DAYLIGHT_CCTS), 5);   % CCT Duv Rf Rg Rcs1
for i = 1:numel(DAYLIGHT_CCTS)
    v = max(cie_daylight_spd(DAYLIGHT_CCTS(i), wl, D.dayBasis), 0);
    r = compute_tm30(v, wl, D);
    dCols(:,i) = v;
    dMeta(i,:) = [r.CCT r.Duv r.Rf r.Rg r.Rcs(1)];
end
fprintf('  daylights: %d\n', numel(DAYLIGHT_CCTS));

% --- (2) extract the high-fidelity sources from the 401 set ---
fprintf('Screening the 401 illuminants (Rf>=%g, Rg>=%g)...\n', RF_MIN, RG_MIN);
src = data.illuminants_401;
assert(max(abs(src(:,1)-wl)) < 1e-9, '401 grid must be 380:5:780.');
illum = src(:,2:end);
mCols = []; mMeta = []; nValid = 0;
for j = 1:size(illum,2)
    v = illum(:,j);
    if ~any(v > 0), continue; end
    nValid = nValid + 1;
    r = compute_tm30(v, wl, D);
    if r.Rf >= RF_MIN && r.Rg >= RG_MIN
        mCols(:,end+1) = max(v,0);
        mMeta(end+1,:) = [r.CCT r.Duv r.Rf r.Rg r.Rcs(1)];   % Rcs,h1 kept for reference
    end
    if mod(j,100)==0, fprintf('  screened %d/%d (kept %d)\n', j, size(illum,2), size(mCols,2)); end
end
fprintf('  401 valid: %d, passing screen: %d\n', nValid, size(mCols,2));

% --- write outputs ---
cols = [dCols, mCols];
main = [wl, cols];                          % [81 x (1+183)] wl + illuminants

% update the main set inside the consolidated data store
data.main_illuminants = main;
save(fullfile(dataDir, 'data.mat'), 'data', '-v7.3');
clear load_data                                     % drop the stale cached store
fprintf('Updated data.main_illuminants in data.mat: %d wl x %d illuminants\n', ...
        size(main,1), size(cols,2));

meta = [dMeta; mMeta];
types = [repmat("daylight", size(dMeta,1), 1); repmat("measured", size(mMeta,1), 1)];
fid = fopen(OUT_META, 'w');
fprintf(fid, 'index,type,CCT,Duv,Rf,Rg,Rcs_h1\n');
for k = 1:size(meta,1)
    fprintf(fid, '%d,%s,%.1f,%.4f,%.2f,%.2f,%.2f\n', k, types(k), ...
            meta(k,1), meta(k,2), meta(k,3), meta(k,4), meta(k,5));
end
fclose(fid);
fprintf('Wrote %s\n', OUT_META);

fprintf('\nTotal main illuminants: %d (%d daylight + %d measured)\n', ...
        size(cols,2), size(dMeta,1), size(mMeta,1));
fprintf('CCT range [%.0f, %.0f] K\n', min(meta(:,1)), max(meta(:,1)));
fprintf('Rf range [%.1f, %.1f], Rg range [%.1f, %.1f]\n', ...
        min(meta(:,3)), max(meta(:,3)), min(meta(:,4)), max(meta(:,4)));
