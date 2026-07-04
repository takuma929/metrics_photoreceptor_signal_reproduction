% First developed by ACS, modified by TM.
% validate_tm30.m  Validate the pure-MATLAB compute_tm30 against the
% colour-science oracle (results/tm30_oracle_*.{mat,csv}).
clearvars; close all; clc;

% --- project paths (location-independent) ---
projectRoot = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(fullfile(projectRoot, 'data'));
addpath(fullfile(projectRoot, 'results'));
dataDir = fullfile(projectRoot, 'data');
resDir  = fullfile(projectRoot, 'results');
figsDir = fullfile(projectRoot, 'figs');
if ~exist(figsDir, 'dir'); mkdir(figsDir); end

D = load_tm30_data(dataDir);

fprintf('=== stagewise anchors (FL2 / D65 / A) ===\n');
S = load(fullfile(resDir, 'tm30_oracle_stagewise.mat'));
names = {'FL2','D65','A'};
for i = 1:numel(names)
    nm = names{i};
    spd = double(S.([nm '_test_sd'])); spd = spd(:);
    o   = double(S.([nm '_scalars']));            % [CCT Duv Rf Rg Rcs1]
    r   = compute_tm30(spd, D.wl, D);
    fprintf(['%-4s  CCT %8.2f/%8.2f  Duv %+.5f/%+.5f  Rf %7.3f/%7.3f  ' ...
             'Rg %7.3f/%7.3f  Rcs1 %+7.3f/%+7.3f\n'], nm, ...
             r.CCT,o(1), r.Duv,o(2), r.Rf,o(3), r.Rg,o(4), r.Rcs(1),o(5));
end

fprintf('\n=== 401 Houser illuminants vs oracle ===\n');
src = readmatrix(fullfile(dataDir, '401Illuminants.csv'));
wl = src(:,1); illum = src(:,2:end);
O = readmatrix(fullfile(resDir, 'tm30_oracle_401.csv'));   % idx CCT Duv Rf Rg Rcs1
n = size(illum,2);
mine = nan(n,5);
for j = 1:n
    v = illum(:,j);
    if ~any(v>0), continue; end
    r = compute_tm30(v, wl, D);
    mine(j,:) = [r.CCT r.Duv r.Rf r.Rg r.Rcs(1)];
end
valid = all(isfinite(mine),2) & all(isfinite(O(:,2:6)),2);
lab = {'CCT','Duv','Rf','Rg','Rcs1'};
for c = 1:5
    dd = mine(valid,c) - O(valid,c+1);
    fprintf('  %-5s  max|diff| %10.5f   mean|diff| %10.6f\n', lab{c}, ...
            max(abs(dd)), mean(abs(dd)));
end

% does the main screen (Rf>=85 & Rg>=90) pick the SAME set?
selO = O(:,4)>=85 & O(:,5)>=90 & valid;
selM = mine(:,3)>=85 & mine(:,4)>=90 & valid;
fprintf('  screen: oracle keeps %d, MATLAB keeps %d, disagree on %d\n', ...
        sum(selO), sum(selM), sum(selO~=selM));

fprintf('\n=== daylight phases 4000:250:20000 vs oracle ===\n');
Od = readmatrix(fullfile(resDir, 'tm30_oracle_daylight.csv')); % cct_nom CCT Duv Rf Rg Rcs1
ccts = Od(:,1);
mined = nan(numel(ccts),5);
for j = 1:numel(ccts)
    v = cie_daylight_spd(ccts(j), D.wl, D.dayBasis);
    r = compute_tm30(v, D.wl, D);
    mined(j,:) = [r.CCT r.Duv r.Rf r.Rg r.Rcs(1)];
end
for c = 1:5
    dd = mined(:,c) - Od(:,c+1);
    fprintf('  %-5s  max|diff| %10.5f   mean|diff| %10.6f\n', lab{c}, ...
            max(abs(dd)), mean(abs(dd)));
end
fprintf('\nDONE\n');
