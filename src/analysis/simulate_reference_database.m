% script to produce the simulate real-world spectra and primaries of a CRT,
% LCD, and Display ++ display, and on two hypothetical five primary displays
% First developed by ACS, modified by TM.

%% prepare workspace

if exist('runningFromWrapper','var') && runningFromWrapper
    keepVars = {'runningFromWrapper','realWorldDataset','forceResimulate','bitDepths','datasets','d','b','bitLabel','datasetLabel','failures'};
    clearvars('-except', keepVars{:});
else
    clear all;
end
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


%% choose dataset for real-world spectra
% Set to 'TM30' to use the original TM-30 reflectance+illuminant simulation.
% Set to a folder path containing SpectroSense CSV files to use the new dataset.

if ~exist('realWorldDataset','var') || isempty(realWorldDataset)
    realWorldDataset = 'TM30';
end

if isfolder(realWorldDataset)
    [~, datasetLabel] = fileparts(realWorldDataset);
else
    datasetLabel = realWorldDataset;
end

datasetLabel = regexprep(datasetLabel,'[^A-Za-z0-9]','_');
datasetLabel = regexprep(datasetLabel,'_+','_');
if isempty(datasetLabel)
    datasetLabel = 'TM30';
end

if ~exist('forceResimulate','var') || isempty(forceResimulate)
    forceResimulate = false;
end

% Ensure results directory exists and use it for saved databases
resultsDir = resDir;
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end
databaseFile = fullfile(resultsDir, ['photosimReferenceDatabase_' datasetLabel '.mat']);

%% check if file already exists, and ask user if they want to re-run simulation

if exist(databaseFile, 'file') == 2 && ~forceResimulate
    if exist('runningFromWrapper','var') && runningFromWrapper
        % In wrapper mode, do not prompt; load existing database.
        resimulate = 'n';
    else
        % if file exists, ask user if they just want to load in file
        resimulate = input(['Do you want to re-run the simulation for dataset ' datasetLabel ' (y/n)? '],'s');
    end
else
    % if the file doesn't exist, or forceResimulate is enabled, simulate
    resimulate ='y';
end

%% if user wants to resimulate gamuts, or if simulated gamuts file does
% not exist then simulate photoreceptor signals then simulate
% else load the file
    
if resimulate == 'y'
    disp('Generating real world reference database and retrieving display calibration data...')
    disp('...this script should only take a few seconds to run...')
    %% set up colorimetry
    % Consolidated data store
    data = load_data();

    % Get the CIE 2015 10degree XYZ functions
    T_xyz = data.cmf_xyz_2012_10deg;
    wls_xyz = T_xyz(:, 1);
    T_xyz_M = 683*T_xyz(wls_xyz >= 400 & wls_xyz <= 699, 2:end)';
    wls_xyz_M = wls_xyz(wls_xyz >= 400 & wls_xyz <= 699, 1);
    T_xyz = 683*T_xyz(wls_xyz >= 390 & wls_xyz <= 780, 2:end)';
    wls_xyz = wls_xyz(wls_xyz >= 390 & wls_xyz <= 780, 1);
    wls_xyz = [];
    
    % Get the photoreceptor spectral sensitivities
    % S, M, L, Rod, Mel
    ss = get_cies026;
    wlsCIES026 = (390:1:780)';
    T_cies026 = ss(:,11:end);
    T_cies026(isnan(T_cies026)) = 0;
    
    %% load in the primaries for the CRT
    wlsCRT = data.crt.wl;
    rgbCRT = data.crt.rgb(wlsCRT >= 390 & wlsCRT <= 780, :);
    
    % calculate xyY coordinates of each individual primary on max for the CRT
    xyYCRT = xyz_to_xyy(T_xyz*rgbCRT);
    idxCRT = convhull(xyYCRT(1,:), xyYCRT(2,:));
    
    %% load in primaries for the Display++
    wlsDP = data.displaypp.wl';
    rgbDP = data.displaypp.rgb(wlsDP >= 390 & wlsDP <= 780, :);
    
    % calculate xyY coordinates of each individual primary on max for the Display++
    xyYDP = xyz_to_xyy(T_xyz*rgbDP);
    idxDP = convhull(xyYDP(1,:), xyYDP(2,:));
    
    %% load in primaries for the LCD
    wlsLCD = data.lcd.wl';
    rgbLCD = data.lcd.rgb(wlsLCD >= 390 & wlsLCD <= 780, :);
    
    % calculate xyY coordinates of each individual primary on max for the  LCD
    xyYLCD = xyz_to_xyy(T_xyz*rgbLCD);
    idxLCD = convhull(xyYLCD(1,:), xyYLCD(2,:));
    
    %% simulate a hypothetical narrowband 5-primary display
    
    nb5pR = normpdf(390:780,450,(10./2.355));
    nb5pG = normpdf(390:780,500,(10./2.355));
    nb5pB = normpdf(390:780,550,(10./2.355));
    nb5pC = normpdf(390:780,600,(10./2.355));
    nb5pM = normpdf(390:780,650,(10./2.355));
    wlsnb5p = [390:780];
    rgbcmnb5p = [nb5pR',nb5pG',nb5pB',nb5pC',nb5pM'];
    
    % noramlise so area under primaries is 1
    for i=1:size(rgbcmnb5p,2)
        % calculate integral of illuminant spectra
        A(i) = trapz(wlsnb5p, rgbcmnb5p(:,i));
        rgbcmnb5p(:,i) = rgbcmnb5p(:,i)./A(i);
    end
    
    % calculate xyY coordinates of primaries on max of LCD
    xyYnb5p = xyz_to_xyy(T_xyz*rgbcmnb5p);
    idxnb5p = convhull(xyYnb5p(1,:), xyYnb5p(2,:));
    
    %% simulate a hypothetical broadband 8-bit 5-primary display
    
    bb5pR = normpdf(390:780,450,(40./2.355));
    bb5pG = normpdf(390:780,500,(40./2.355));
    bb5pB = normpdf(390:780,550,(40./2.355));
    bb5pC = normpdf(390:780,600,(40./2.355));
    bb5pM = normpdf(390:780,650,(40./2.355));
    wlsbb5p = [390:780];
    rgbcmbb5p = [bb5pR',bb5pG',bb5pB',bb5pC',bb5pM'];
    
    % noramlise so area under primaries is 1
    for i=1:size(rgbcmbb5p,2)
        % calculate integral of illuminant spectra
        A(i) = trapz(wlsbb5p, rgbcmbb5p(:,i));
        rgbcmbb5p(:,i) = rgbcmbb5p(:,i)./A(i);
    end
    
    % calculate xyY coordinates of primaries on max of LCD
    xyYbb5p = xyz_to_xyy(T_xyz*rgbcmbb5p);
    idxbb5p = convhull(xyYbb5p(1,:), xyYbb5p(2,:));
    
     %% and load in the primaries for Oxford MPHDR display
    wls_mphdr = data.mphdr.wl';
    rgbcmMPHDR = data.mphdr.rgbcmy(wls_mphdr >= 390 & wls_mphdr <= 780, :);
    
    % calculate xyY coordinates of each individual primary on max
    xyYMPHDR = xyz_to_xyy(T_xyz*rgbcmMPHDR);
    idxMPHDR = convhull(xyYMPHDR(1,:), xyYMPHDR(2,:));
    
    % Get the photoreceptor spectral sensitivities
    % S, M, L, Rod, Mel
    % convert to 400-700nm range!
    ss = get_cies026;
    wlsCIES026_M = (400:1:699)';
    T_cies026_M = ss(:,11:310);
    T_cies026_M(isnan(T_cies026_M)) = 0;
    
    %% and load in the Nugent Zele system
    wls_nz = data.nugent_zele.wl;
    rgbcm_finespace = data.nugent_zele.primaries(wls_nz>=390 & wls_nz<=780, :);
    rgbcmNZ = rgbcm_finespace(1:4:length(rgbcm_finespace),:);
    
    xyYNZ = xyz_to_xyy(T_xyz*rgbcmNZ);
    idxNZ = convhull(xyYNZ(1,:), xyYNZ(2,:));
    
    %% load in the primaries for the Manchester 5 primary display
    manchester_primaries = data.manchester.primaries;
    manchester_wls = data.manchester.wl;
    
    wlsMan = manchester_wls(:,1);
    rgbcmMan = manchester_primaries(manchester_wls >= 390 & manchester_wls <= 780, 1:end);
    
    % calculate xyY coordinates of each individual primary on max 
    xyYMan = xyz_to_xyy(T_xyz_M*rgbcmMan);
    idxMan = convhull(xyYMan(1,:), xyYMan(2,:));
    
    %% get spectral and daylight locus
    
    slRad = get_spectral_locus_spectra(390:780); % get spectral locus from 390:780
    
    %% get simulated radiant spectra
    
    simRad = get_simulated_spectra(realWorldDataset);
    
    % If the simulated spectra are in 1nm spacing, downsample to 5nm
    % so they match the 5nm colorimetry matrices used below.
    if size(simRad,1) == 391
        simRad = simRad(1:5:end, :);
    end
    
    %% set up 5nm spacing colorimetry (for simulated spectra and daylight locus)
    wls_xyz = T_xyz(:, 1);
    T_xyz_5nm = 683*T_xyz(wls_xyz >= 390 & wls_xyz <= 780, 2:end)';
    wls_xyz = wls_xyz(wls_xyz >= 390 & wls_xyz <= 780, 1);
    % scale for spds with 5nm spacing
    wls_xyz_5nm = wls_xyz(1:5:end);
    T_xyz_5nm = T_xyz(:,1:5:end);
    
    % rescale only over range where we have cone fundmanetals i.e. 390nm:780nm
    % scale for spds with 5nm spacing
    wls_cies026_5nm = wlsCIES026(1:5:end);
    T_cies026_5nm = T_cies026(:,1:5:end);
    % remove Nans
    T_cies026_5nm(isnan(T_cies026_5nm)) = 0;
    
    %% set up MacLeod-Boynton chromaticity coordinates
    lScale = 0.69283932; 
    mScale = 0.34967567;
    sScale = 0.05547858;
    
    % scale factors from CVRL MacLeod & Boynton (1979) 10-deg chromaticity 
    % coordinates based on the Stockman & Sharpe (2000) cone fundamentals: http://www.cvrl.org/    

    mb026(2,:) = T_cies026(2,:)*mScale;
    mb026(3,:) = T_cies026(3,:)*lScale;
    mb026(1,:) = T_cies026(1,:)*sScale;
    
    iScale = 1./(max(T_cies026(5,:)./(mb026(2,:)+mb026(3,:)))); % scale melanopsin spectral sensitivity so that I/L+M peaks at 1
    mb026(5,:) = T_cies026(5,:)*iScale;
    
    % rescale only over range where we have cone fundmanetals i.e. 390nm:780nm
    % scale for spds with 5nm spacing
    mb026_5nm = mb026(:,1:5:end);
    % remove Nans
    mb026_5nm(isnan(mb026_5nm)) = 0;
    mb026(isnan(mb026))=0;
    
    %% calculate xyY and photoreceptor activations of spectral locus
    
    % calculate xyY coordinates of spectral locus
    xyYSL = xyz_to_xyy(T_xyz*slRad);
    idxSL = convhull(xyYSL(1,:), xyYSL(2,:));
    
    % calculate photoreceptor activations of spectral locus
    ssSL = T_cies026*slRad;
    ssmbSL = mb026*slRad;
    mbSL(1,:) = ssmbSL(3,:)./(ssmbSL(2,:)+ssmbSL(3,:));
    mbSL(2,:) = ssmbSL(1,:)./(ssmbSL(2,:)+ssmbSL(3,:));
    mbSL(3,:) = ssmbSL(5,:)./(ssmbSL(2,:)+ssmbSL(3,:));
    
    %% calculate xyY and photoreceptor activations of simulated spectra
    
    % calculate xyY coordinates of simulated spectra
    xyYSim = xyz_to_xyy(T_xyz_5nm*simRad);
    
    % calculate photoreceptor activations of simulated spectra
    ssSim = T_cies026_5nm*simRad;
    ssmbSim = mb026_5nm*simRad;
    mbSim(1,:) = ssmbSim(3,:)./(ssmbSim(2,:)+ssmbSim(3,:));
    mbSim(2,:) = ssmbSim(1,:)./(ssmbSim(2,:)+ssmbSim(3,:));
    mbSim(3,:) = ssmbSim(5,:)./(ssmbSim(2,:)+ssmbSim(3,:));
    
    %% calculate photoreceptor correlations of simulated spectra
    pairs = [1,2;1,3;1,4;1,5;2,3;2,4;2,5;3,4;3,5;4,5];
    pairNames = ['S','M';'S','L';'S','R';'S','I';'M','L';'M','R';'M','I';'L','R';'L','I';'R','I'];
    for i=1:length(pairs)
        [rho{i}, pval{i}] = corrcoef(ssSim(pairs(i,1),:),ssSim(pairs(i,2),:));
        photoreceptorCorrelations(i) = rho{i}(1,2);
    end
    correlationLabels = pairNames;
    
    %% save output
    NZ = struct('xyYMax', xyYNZ, 'idx', idxNZ, 'spd', rgbcmNZ);
    Man = struct('xyYMax', xyYMan, 'idx', idxMan, 'spd', rgbcmMan);
    MPHDR = struct('xyYMax', xyYMPHDR, 'idx', idxMPHDR, 'spd', rgbcmMPHDR);
    CRT = struct('xyYMax', xyYCRT, 'idx', idxCRT, 'spd', rgbCRT);
    DP = struct('xyYMax', xyYDP, 'idx', idxDP, 'spd', rgbDP);
    LCD = struct('xyYMax', xyYLCD, 'idx', idxLCD, 'spd', rgbLCD);
    nb5p = struct('xyYMax', xyYnb5p, 'idx', idxnb5p, 'spd', rgbcmnb5p);
    bb5p = struct('xyYMax', xyYbb5p, 'idx', idxbb5p, 'spd', rgbcmbb5p);
    Sim = struct('xyY', xyYSim, 'ss', ssSim, 'mb', mbSim, 'photoreceptorCorrelations', photoreceptorCorrelations, 'correlationLabels', correlationLabels);
    SL = struct('xyY', xyYSL, 'idx', idxSL, 'ss', ssSL, 'mb', mbSL);
    
    % Save only the dataset-tagged database. No generic un-tagged copy is
    % written, so a different dataset's database can never be loaded by mistake.
    save(databaseFile,'NZ','CRT','DP','LCD','nb5p','bb5p','Sim','SL','Man','MPHDR','datasetLabel');
    
    % load final struct
    load(databaseFile)
    disp('...done')
%% else load the file
else
    disp('Loading file...')
    load(databaseFile)
    disp('...done')
end
