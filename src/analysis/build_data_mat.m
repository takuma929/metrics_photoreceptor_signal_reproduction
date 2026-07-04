% First developed by ACS, modified by TM.
% build_data_mat.m
% Assemble the single consolidated data store data/data.mat from the raw source
% files archived under legacy/data_sources/. Every dataset becomes a field of a
% single struct `data` with a meaningful, lower-case, underscore-separated name.
%
% Run this once to (re)create data/data.mat. Downstream code loads the store via
% load_data(). The generated fields data.main_illuminants and
% data.asano_observers are seeded here from their current files and refreshed by
% build_main_illuminants.m / run_asano_cie2006.m.
clearvars; close all; clc;

% --- project paths (location-independent) ---
projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(genpath(fullfile(projectRoot, 'src')));
srcDir  = fullfile(projectRoot, 'legacy', 'data_sources');
dataDir = fullfile(projectRoot, 'data');
if ~exist(dataDir, 'dir'); mkdir(dataDir); end

R = @(f) readmatrix(fullfile(srcDir, f));
L = @(f) load(fullfile(srcDir, f));

data = struct();

%% real-world spectra ------------------------------------------------------
data.illuminants_401        = R('401Illuminants.csv');            % [81 x 402] wl + 401
data.illuminants_401_types  = readcell(fullfile(srcDir,'401Illuminants_sampleTypes.csv'));
data.reflectances_99        = R('99Reflectances.csv');           % [401 x 100] wl + 99
data.reflectances_99_types  = readcell(fullfile(srcDir,'99Reflectances_sampleTypes.csv'));
data.main_illuminants = R('mainIlluminants.csv');% [81 x 184] wl + 183 (generated)

%% display primaries (each: wl + primary matrix) --------------------------
crt = L('CRT/RGBPhospher.mat');                                   % RGBPhospher [461 x 4]
data.crt.wl  = crt.RGBPhospher(:,1);
data.crt.rgb = crt.RGBPhospher(:,2:4);

rL = L('LCD/red.mat'); gL = L('LCD/green.mat'); bL = L('LCD/blue.mat');
data.lcd.wl  = rL.Lambda(:);
data.lcd.rgb = [rL.Radiance(:), gL.Radiance(:), bL.Radiance(:)];

rD = L('display++/Red.mat'); gD = L('display++/Green.mat'); bD = L('display++/Blue.mat');
data.displaypp.wl  = rD.Lambda(:);
data.displaypp.rgb = [rD.Radiance(:), gD.Radiance(:), bD.Radiance(:)];

mp = L('MPHDR.mat');                                             % mphdrRGBCMY [401 x 6], wls [1 x 401]
data.mphdr.wl     = mp.wls(:);
data.mphdr.rgbcmy = mp.mphdrRGBCMY;

man = readtable(fullfile(srcDir,'Manchester_5Primary.xlsx'));    % Var1(wl), V,C,G,Y,R
data.manchester.wl        = table2array(man(:,1));
data.manchester.primaries = table2array(man(:,2:6));             % [301 x 5] V C G Y R

nz = readtable(fullfile(srcDir,'NugentZeleSystemSpectra.xlsx')); % Wavelength, Violet..Red
data.nugent_zele.wl        = nz.Wavelength;
data.nugent_zele.primaries = [nz.Violet, nz.Cyan, nz.Green, nz.Amber, nz.Red];  % [1656 x 5]

%% colour matching functions / TM-30 static data --------------------------
data.cmf_xyz_2012_10deg = R('lin2012xyz10e_1_7sf.csv');          % [441 x 4] wl + XYZ
xyz64 = L('T_xyz1964.mat');
data.cmf_xyz_1964.T = xyz64.T_xyz1964;                           % [3 x 471]
data.cmf_xyz_1964.S = xyz64.S_xyz1964;                           % [1 x 3]
data.tm30_cmf_2deg      = R('tm30_cmf_2deg_5nm.csv');            % [81 x 4]
data.tm30_cmf_10deg     = R('tm30_cmf_10deg_5nm.csv');           % [81 x 4]
data.tm30_tcs           = R('tm30_tcs_5nm.csv');                 % [81 x 100]
data.cie_daylight_basis = R('cie_daylight_basis_5nm.csv');       % [81 x 4]

%% cone models / Asano individual observers -------------------------------
asano = L('Asano_individual_cone_fundamentals.mat');
data.asano_observers = asano.out;                                % generated struct
data.cie2006_lms_absorbance = R('cie2006_LMSAbsorbance.txt');
data.cie2006_macular_density = R('cie2006_RelativeMacularDensity.txt');
data.cie2006_docul           = R('cie2006_docul.txt');

%% misc / supplementary ---------------------------------------------------
refl = L('reflectance.mat');   data.reflectance = refl.reflectance;
socs = L('SOCSDatasets.mat');  data.socs_reflectance = socs.Reflectance; data.socs_id = socs.SOCS_Id;
dspd = L('DSPD.mat');          data.dspd = dspd.DSPD;
figp = L('photoSim_FigParameters.mat'); data.fig_parameters = figp.figp;

%% save -------------------------------------------------------------------
outFile = fullfile(dataDir, 'data.mat');
save(outFile, 'data', '-v7.3');
finfo = dir(outFile);
fprintf('Wrote %s (%.1f MB)\n', outFile, finfo.bytes/1e6);
fprintf('Fields: %s\n', strjoin(fieldnames(data), ', '));
