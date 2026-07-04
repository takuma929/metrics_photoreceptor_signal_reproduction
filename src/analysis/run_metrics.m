% simulate distortions
% First developed by ACS, modified by TM.

%% prepare workspace

if exist('runningFromWrapper','var') && runningFromWrapper
    keepVars = {'runningFromWrapper','realWorldDataset','displayBitDepth','forceResimulate','bitDepths','datasets','d','b','bitLabel','datasetLabel','failures'};
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





% Choose the dataset to use for real-world spectra.
% Set to 'TM30' to use the original TM-30 reflectance+illuminant dataset,
% or set to a folder path containing SpectroSense CSV files.
if ~exist('realWorldDataset','var') || isempty(realWorldDataset)
    realWorldDataset = 'TM30'; % or 'data/28176839/SpectroSense Dataset'
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

databaseFile = ['photosimReferenceDatabase_' datasetLabel '.mat'];

% Choose a display bit depth for quantized reproduction.
% Set to Inf for continuous weights, or 8/10/12 to include quantization.
if ~exist('displayBitDepth','var') || isempty(displayBitDepth)
    displayBitDepth = Inf;
end
if ~exist('forceResimulate','var') || isempty(forceResimulate)
    forceResimulate = false;
end
epsilon = 0.01; % define tolerance value

%% load in photoreceptor signals
load(databaseFile);

%% specify distortion matrix
% i.e. which signals are to be fixed 1=S, 2=M, 3=L, 4=R, 5=I
distortionMatrix = '_ReproduceLMS';
matchedSignals = [1,2,3];

if isfinite(displayBitDepth)
    bitDepthLabel = sprintf('%dbit', displayBitDepth);
else
    bitDepthLabel = 'Inf';
end

%% check if the type of distortion already exists
% Ensure results directory exists and save metrics there
resultsDir = resDir;
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end
% Single source of truth: every saved/loaded metrics file is tagged with its
% dataset and bit depth. No generic un-tagged "base" file is written, so a
% wrong-condition file can never be silently picked up later.
fileName = fullfile(resultsDir, ['photosimMetrics' distortionMatrix, '_' datasetLabel, '_' bitDepthLabel, '.mat']);
if exist(fileName, 'file')==2 && ~forceResimulate
    if exist('runningFromWrapper','var') && runningFromWrapper
        % In wrapper mode, do not prompt for input; load existing metrics.
        resimulate = 'n';
    else
        % if file exists, ask user if they just want to load in file
        resimulate = input('Do you want to re-run the simulation (y/n)? ','s');
    end
else
    % if the file doesn't exist, or forceResimulate is enabled, simulate
    resimulate ='y';
end

%% if user wants to resimulate gamuts, or if simulated gamuts file does
% not exist then simulate photoreceptor signals then simulate
% else load the file

if resimulate =='y'
    %% find photoreceptor signal distortions introduced when attempting to preproduce real-world spectra on the display
    % Get the photoreceptor spectral sensitivities
    % S, M, L, Rod, Mel
    ss = get_cies026;
    wlsCIES026 = (390:1:780)';
    %wlsCIES026 = (390:1:780)';
    T_cies026 = ss(:,11:end);
    %T_cies026 = ss(:,21:321);
    T_cies026(isnan(T_cies026)) = 0;
    
    % set up MacLeod-Boynton chromaticity coordinates
    lScale = 0.69283932; 
    mScale = 0.34967567;
    sScale = 0.05547858;
    
    % scale factors from CVRL MacLeod & Boynton (1979) 10-deg chromaticity 
    % coordinates based on the Stockman & Sharpe (2000) cone fundamentals: http://www.cvrl.org/    
    mb026(2,:) = T_cies026(2,:)*mScale;
    mb026(3,:) = T_cies026(3,:)*lScale;
    mb026(1,:) = T_cies026(1,:)*sScale;
    
    iScale = 1./max(T_cies026(5,:)./(mb026(2,:)+mb026(3,:))); % so I/L+M peaks at 1
    mb026(5,:) = T_cies026(5,:)*iScale;
    
    % rescale only over range where we have cone fundmanetals i.e. 390nm:780nm
    % scale for spds with 5nm spacing
    mb026_5nm = mb026(:,1:5:end);
    % remove Nans
    mb026_5nm(isnan(mb026_5nm)) = 0;
    mb026(isnan(mb026))=0;
    
    % Get the photoreceptor spectral sensitivities - and in the spacing for
    % the Manchester display
    % S, M, L, Rod, Mel
    ss = get_cies026;
    wlsCIES026_M = (400:1:699)';
    T_cies026_M = ss(:,11:310);
    T_cies026_M(isnan(T_cies026_M)) = 0;
    
    % set up MacLeod-Boynton chromaticity coordinates
    lScale = 0.69283932; 
    mScale = 0.34967567;
    sScale = 0.05547858;
    
    % scale factors from CVRL MacLeod & Boynton (1979) 10-deg chromaticity 
    % coordinates based on the Stockman & Sharpe (2000) cone fundamentals: http://www.cvrl.org/    

    mb026_M(2,:) = T_cies026_M(2,:)*mScale;
    mb026_M(3,:) = T_cies026_M(3,:)*lScale;
    mb026_M(1,:) = T_cies026_M(1,:)*sScale;
    
    iScale = 1./max(T_cies026_M(5,:)./(mb026_M(2,:)+mb026_M(3,:))); % so I/L+M peaks at 1
    mb026_M(5,:) = T_cies026_M(5,:)*iScale;
    
    % rescale only over range where we have cone fundmanetals i.e. 390nm:780nm
    % scale for spds with 5nm spacing
    mb026_5nm_M = mb026_M(:,1:5:end);
    % remove Nans
    mb026_5nm_M(isnan(mb026_5nm_M)) = 0;
    mb026_M(isnan(mb026_M))=0;
    
    % define smallest bit increment for display
    smallestBit = 1./256;
    if isfinite(displayBitDepth)
        bitDepth = displayBitDepth;
    else
        bitDepth = [];
    end
    
    % get signal distortions for five displays
    disp('Step 1/3: Calculating distorted spectra for each display...');
    disp('...this may take several minutes...')
    [CRT] = get_distortions(matchedSignals,Sim,CRT,CRT.spd,T_cies026,mb026,smallestBit,3,epsilon,bitDepth);
    disp('...display 1/8 done...');
    [LCD] = get_distortions(matchedSignals,Sim,LCD,LCD.spd,T_cies026, mb026,smallestBit,3,epsilon,bitDepth);
    disp('...display 2/8 done...');
    [DP] = get_distortions(matchedSignals,Sim,DP,DP.spd,T_cies026, mb026, smallestBit,3,epsilon,bitDepth);
    disp('...display 3/8 done...');
    [nb5p] = get_distortions(1:5,Sim,nb5p,nb5p.spd,T_cies026, mb026, smallestBit,5,epsilon,bitDepth);
    disp('...display 4/8 done...');
    [bb5p] = get_distortions(1:5,Sim,bb5p,bb5p.spd,T_cies026, mb026, smallestBit,5,epsilon,bitDepth);
    disp('...display 5/8 done...');
    [Man] = get_distortions(1:5,Sim,Man,Man.spd,T_cies026_M, mb026_M, smallestBit,5,epsilon,bitDepth);
    disp('...display 6/8 done...');
    [MPHDR] = get_distortions(1:5,Sim,MPHDR,MPHDR.spd,T_cies026, mb026, smallestBit,6,epsilon,bitDepth);
    disp('...display 7/8 done...');
    [NZ] = get_distortions(1:5,Sim,NZ,NZ.spd,T_cies026, mb026, smallestBit,5,epsilon,bitDepth);
    disp('...display 8/8 done...');
    disp('...done');

    % get photoreceptor distortion metrics, PSDM, for five displays
    disp('Step 2/3: Running metrics...');
    disp('...this should take seconds...')
    [CRT] = get_psdm(CRT,Sim);
    [LCD] = get_psdm(LCD,Sim);
    [DP] = get_psdm(DP,Sim);
    [nb5p] = get_psdm(nb5p,Sim);
    [bb5p] = get_psdm(bb5p,Sim);
    [Man] = get_psdm(Man,Sim);
    [MPHDR] = get_psdm(MPHDR,Sim);
    [NZ] = get_psdm(NZ,Sim);
    
    % get photoreceptor correlation distortions
%     [CRT] = get_pcdm(CRT,Sim);
%     [LCD] = get_pcdm(LCD,Sim);
%     [DP] = get_pcdm(DP,Sim);
%     [nb5p] = get_pcdm(nb5p,Sim);
%     [bb5p] = get_pcdm(bb5p,Sim);
%     [Man] = get_pcdm(Man,Sim);
%     [MPHDR] = get_pcdm(MPHDR,Sim);
%     [NZ] = get_pcdm(NZ,Sim);
    
    % get real world reproduction metric
    [CRT] = get_psrm(CRT,Sim,epsilon);
    [LCD] = get_psrm(LCD,Sim,epsilon);
    [DP] = get_psrm(DP,Sim,epsilon);
    [nb5p] = get_psrm(nb5p,Sim,epsilon);
    [bb5p] = get_psrm(bb5p,Sim,epsilon);
    [Man] = get_psrm(Man,Sim,epsilon);
    [MPHDR] = get_psrm(MPHDR,Sim,epsilon);
    [NZ] = get_psrm(NZ,Sim,epsilon);
    
    % get chromaticity diagram reproduciton metric
    [CRT] = get_colour_gamut(CRT,Sim);
    [LCD] = get_colour_gamut(LCD,Sim);
    [DP] = get_colour_gamut(DP,Sim);
    [nb5p] = get_colour_gamut(nb5p,Sim);
    [bb5p] = get_colour_gamut(bb5p,Sim);
    [Man] = get_colour_gamut(Man,Sim);
    [MPHDR] = get_colour_gamut(MPHDR,Sim);
    [NZ] = get_colour_gamut(NZ,Sim);
    
    disp('...done');
    %% save output
    disp('Step 3/3: Saving output...');
    disp('...this should take seconds...')
    save(fileName,'CRT','LCD','DP','nb5p','bb5p','Sim','SL','Man','MPHDR','NZ','datasetLabel','displayBitDepth');

    if exist('runningFromWrapper','var') && runningFromWrapper
        % preserve wrapper variables instead of clearing them
    else
        clearvars -except fileName
    end

    load(fileName);
    fprintf('\nrun_metrics: Loaded metrics from %s\n', fileName);
    fprintf('  dataset=%s  bitDepth=%s\n', datasetLabel, bitDepthLabel);
    fprintf('  CRT.psdm=%.8f  LCD.psdm=%.8f  DP.psdm=%.8f\n', CRT.psdm, LCD.psdm, DP.psdm);
    fprintf('  nb5p.psdm=%.8f  bb5p.psdm=%.8f  Man.psdm=%.8f  MPHDR.psdm=%.8f  NZ.psdm=%.8f\n\n', nb5p.psdm, bb5p.psdm, Man.psdm, MPHDR.psdm, NZ.psdm);

    % Publish the path actually written so the wrapper/plotting scripts
    % don't have to reconstruct the filename convention themselves.
    metricsFile = fileName;
    clear distortionMatrix fileName matchedSignals resimulate
    disp('...done');
else
    % else load the file
    disp('Loading metrics...');
    if exist(fileName, 'file')~=2
        % Fail loudly rather than loading a different condition's data.
        error('run_metrics:MissingMetrics', ...
            ['Metrics file for dataset=%s bitDepth=%s not found:\n  %s\n' ...
             'Set forceResimulate = true (or delete stale files) to recompute.'], ...
            datasetLabel, bitDepthLabel, fileName);
    end
    load(fileName);
    loadedFile = fileName;

    metricsLoaded = {CRT, LCD, DP, nb5p, bb5p, Man, MPHDR, NZ};
    hasNanPSDM = any(cellfun(@(x) any(isnan(x.psdm(:))), metricsLoaded));
    if hasNanPSDM
        warning('run_metrics:NaNMetrics', 'Loaded metrics file %s contains NaN PSDM values; recomputing and saving corrected metrics.', loadedFile);
        [CRT] = get_psdm(CRT,Sim);
        [LCD] = get_psdm(LCD,Sim);
        [DP] = get_psdm(DP,Sim);
        [nb5p] = get_psdm(nb5p,Sim);
        [bb5p] = get_psdm(bb5p,Sim);
        [Man] = get_psdm(Man,Sim);
        [MPHDR] = get_psdm(MPHDR,Sim);
        [NZ] = get_psdm(NZ,Sim);
        save(fileName,'CRT','LCD','DP','nb5p','bb5p','Sim','SL','Man','MPHDR','NZ','datasetLabel','displayBitDepth');
        loadedFile = fileName;
    end

    fprintf('\nrun_metrics: Loaded metrics from %s\n', loadedFile);
    fprintf('  dataset=%s  bitDepth=%s\n', datasetLabel, bitDepthLabel);
    fprintf('  CRT.psdm=%.8f  LCD.psdm=%.8f  DP.psdm=%.8f\n', CRT.psdm, LCD.psdm, DP.psdm);
    fprintf('  nb5p.psdm=%.8f  bb5p.psdm=%.8f  Man.psdm=%.8f  MPHDR.psdm=%.8f  NZ.psdm=%.8f\n\n', nb5p.psdm, bb5p.psdm, Man.psdm, MPHDR.psdm, NZ.psdm);
    % Publish the path actually loaded (tagged or fallback) for downstream use.
    metricsFile = loadedFile;
    clear distortionMatrix fileName matchedSignals resimulate loadedFile
    disp('...done');
end