% First developed by ACS, modified by TM.
% display_reported_vals.m
% Print the main-text numbers (Sections 3.1 and 3.2) directly from the computed
% metrics, so the manuscript values can be checked against the code. Uses the
% main reference set, which is the main reference set of the paper.
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

load photosimMetrics_ReproduceLMS_Main_Inf.mat

disp('3.1 Reproduced Chromaticity');
disp(['CRT: ',num2str(CRT.chromaticityReproductionMetric)]);
disp(['Dell: ',num2str(LCD.chromaticityReproductionMetric)]);
disp(['disp++: ',num2str(DP.chromaticityReproductionMetric)]);
disp(['Manchester: ',num2str(Man.chromaticityReproductionMetric)]);
disp(['MPHDR: ',num2str(MPHDR.chromaticityReproductionMetric)]);
disp(['NZ: ',num2str(NZ.chromaticityReproductionMetric)]);

disp('3.1 PSRM');
disp(['CRT: ',num2str(CRT.realworldReproductionMetric)]);
disp(['Dell: ',num2str(LCD.realworldReproductionMetric)]);
disp(['Display++: ',num2str(DP.realworldReproductionMetric)]);

disp(['Narrow-band 5P: ',num2str(nb5p.realworldReproductionMetric)]);
disp(['Broad-band 5P: ',num2str(bb5p.realworldReproductionMetric)]);

disp(['Manchester: ',num2str(Man.realworldReproductionMetric)]);
disp(['MPHDR: ',num2str(MPHDR.realworldReproductionMetric)]);
disp(['NZ: ',num2str(NZ.realworldReproductionMetric)]);

disp('3.2 PSDM_Std');
disp(['CRT_R: ',num2str(CRT.stdDistortion(4))]);
disp(['CRT_I: ',num2str(CRT.stdDistortion(5))]);

disp(['Dell_R: ',num2str(LCD.stdDistortion(4))]);
disp(['Dell_I: ',num2str(LCD.stdDistortion(5))]);

disp(['Display++_R: ',num2str(DP.stdDistortion(4))]);
disp(['Display++_I: ',num2str(DP.stdDistortion(5))]);

disp('3.2 PSDM_Mean');
disp(['CRT_R: ',num2str(CRT.meanDistortion(4))]);
disp(['CRT_I: ',num2str(CRT.meanDistortion(5))]);

disp(['Dell_R: ',num2str(LCD.meanDistortion(4))]);
disp(['Dell_I: ',num2str(LCD.meanDistortion(5))]);

disp(['Display++_R: ',num2str(DP.meanDistortion(4))]);
disp(['Display++_I: ',num2str(DP.meanDistortion(5))]);

disp('3.2 PSDM_MeanAbs');
disp(['CRT_R: ',num2str(CRT.meanAbsDistortion(4))]);
disp(['CRT_I: ',num2str(CRT.meanAbsDistortion(5))]);
disp(['Dell_R: ',num2str(LCD.meanAbsDistortion(4))]);
disp(['Dell_I: ',num2str(LCD.meanAbsDistortion(5))]);
disp(['Display++_R: ',num2str(DP.meanAbsDistortion(4))]);
disp(['Display++_I: ',num2str(DP.meanAbsDistortion(5))]);

disp('3.2 PSDM_Oveall');
disp(['CRT: ',num2str(CRT.psdm)]);
disp(['Dell: ',num2str(LCD.psdm)]);
disp(['Display++: ',num2str(DP.psdm)]);



%% bit depth analysis
for bit = [8 10 12]
for type = {'Man','NZ'}
    if strcmp(type{1},'Man')
        display = Man;
    elseif strcmp(type{1},'NZ')
        display = NZ;
    end
    epsilon = 0.01;
    k = max(display.alphaReproduced(:));
    normalized = round(2^bit*(display.alphaReproduced/k));
    display.alphaReproduced_bit = normalized/(2^bit)*k;
    error_bit = abs(display.alphaReproduced_bit - Sim.ss)./Sim.ss;
    psrm_bit.([type{1},'_bit',num2str(bit)]) = sum(sum(error_bit > epsilon, 1) == 0)./length(error_bit)*100;
end
end
disp(psrm_bit)