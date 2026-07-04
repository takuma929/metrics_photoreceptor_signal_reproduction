% First developed by ACS, modified by TM.
% script to get the Monte-Carlo simulated spectra

function rad = get_simulated_spectra(datasetPath)

% Usage:
%   rad = get_simulated_spectra;
%   rad = get_simulated_spectra('TM30');
%   rad = get_simulated_spectra('data/28176839/SpectroSense Dataset');

if nargin < 1 || isempty(datasetPath)
    datasetPath = 'TM30';
end

if ischar(datasetPath) || isstring(datasetPath)
    datasetPath = char(datasetPath);
end

if any(strcmpi(datasetPath, {'TM30','TM-30'}))
    data = load_data();
    rad = simulateReflectanceSpectra(data.illuminants_401, data.reflectances_99);
elseif any(strcmpi(datasetPath, {'Main','MainIlluminants'}))
    % C3: main reference set = CIE daylight phases + the 401-set sources
    % that pass a broadcast-quality fidelity screen (Rf>=85 & Rg>=90).
    % Built by build_main_illuminants.m.
    data = load_data();
    rad = simulateReflectanceSpectra(data.main_illuminants, data.reflectances_99);
elseif strcmpi(datasetPath, 'SpectroSense') || strcmpi(datasetPath, 'SpectroSense Dataset')
    datasetPath = fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))), 'data', '28176839', 'SpectroSense Dataset');
    rad = loadSpectroSenseSpectra(datasetPath);
elseif exist(datasetPath, 'dir') == 7
    rad = loadSpectroSenseSpectra(datasetPath);
else
    error('get_simulated_spectra:UnknownDataset', 'Unknown dataset specified: %s', datasetPath);
end

end

function rad = simulateReflectanceSpectra(illuminants, reflectances)
% Build radiance spectra = reflectance x (unit-area-normalised) illuminant,
% for every illuminant x reflectance pair (illuminant-major order).
% reference: http://dx.doi.org/10.1364/OE.21.010393
% illuminants shares the format/grid of data.illuminants_401:
%   column 1 = wavelength (380:5:780), remaining columns = illuminants.
% reflectances shares the format of data.reflectances_99 (1 nm, 380:780).

% illuminants: drop the first two rows so the grid starts at 390:5:780 (79 pts)
wlsSpd = illuminants(3:end,1);
% cols are different illuminants, rows are diff wavelengths
spd = illuminants(3:end,2:end);

% reflectance spectra (TM-30-15 standard) on the matching 390:5:780 grid
ref = reflectances(11:5:401,2:end);

% normalise illuminant spectra
normSpd = norm_ill_spd(spd, wlsSpd);

% calculate simulated radiant spectra
k = 1;
for i = 1:size(normSpd,2)
    for j = 1:size(ref,2)
        rad(:,k) = (ref(:,j).*normSpd(:,i));
        k = k + 1;
    end
end
end

function rad = loadSpectroSenseSpectra(rootFolder)
% Load SpectroSense calibrated spectra from a directory structure.
pattern = fullfile(rootFolder, '**', '*_calibrated_interp.csv');
files = dir(pattern);
if isempty(files)
    % Fallback for older MATLAB versions that do not support '**' recursion.
    files = [];
    folders = {rootFolder};
    idx = 1;
    while idx <= numel(folders)
        listing = dir(folders{idx});
        listing = listing([listing.isdir]);
        for j = 1:numel(listing)
            if any(strcmp(listing(j).name, {'.','..'}))
                continue;
            end
            folders{end+1} = fullfile(folders{idx}, listing(j).name);
        end
        idx = idx + 1;
    end
    for j = 1:numel(folders)
        moreFiles = dir(fullfile(folders{j}, '*_calibrated_interp.csv'));
        files = [files; moreFiles];
    end
end
if isempty(files)
    error('loadSpectroSenseSpectra:NoFiles', 'No *_calibrated_interp.csv files found in %s', rootFolder);
end

filePaths = fullfile({files.folder}, {files.name});
[filePaths, ~] = sort(filePaths);

wlTarget = (390:780)';
rad = zeros(numel(wlTarget), numel(filePaths));
for i = 1:numel(filePaths)
    data = csvread(filePaths{i}, 1, 0);
    if size(data,2) < 2
        error('loadSpectroSenseSpectra:BadFormat', 'Expected two columns in %s', filePaths{i});
    end
    wls = data(:,1);
    spd = data(:,2);
    spd(isnan(spd)) = 0;
    if any(diff(wls) ~= 1) || numel(wls) < numel(wlTarget) || any(wls(1:numel(wlTarget)) ~= wlTarget)
        spd = interp1(wls, spd, wlTarget, 'pchip', 0);
    else
        idxRange = wls >= 390 & wls <= 780;
        spd = spd(idxRange);
    end
    rad(:,i) = spd;
end
fprintf('Loaded %d spectra from SpectroSense dataset at %s\n', size(rad,2), rootFolder);
end
