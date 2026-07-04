% plot Figures 7 and 8 of the paper
% plots the equal-luminance photoreceptor excitation space and the distorted
% (display-reproducible) versions of it.
%   Figure 7 (12 panels) = leftmost column: the full real-world database
%     (3 projections) + the three-primary displays CRT, LCD, Display++
%     (3 projections each).
%   Figure 8 (15 panels) = the five-primary displays MPHDR, Man, nb5p, bb5p,
%     NZ (3 projections each), using the same axes and colour scale as Fig. 7.
% First developed by ACS, modified by TM.

%% load data
clearvars;close all;clc;

% --- project paths (location-independent) ---
projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(fullfile(projectRoot, 'data'));
addpath(fullfile(projectRoot, 'results'));
dataDir = fullfile(projectRoot, 'data');
resDir  = fullfile(projectRoot, 'results');
figsDir = fullfile(projectRoot, 'figs');
if ~exist(figsDir, 'dir'); mkdir(figsDir); end

     
%% load relevant data file
% Canonical condition for the main-text figures: TM30 dataset, continuous
% (Inf-bit) weights. Resolved relative to this script so it works from any CWD.
metricsFile = fullfile(projectRoot, 'results', 'photosimMetrics_ReproduceLMS_Main_Inf.mat');
load(metricsFile);
figsDir = fullfile(projectRoot, 'figs');
if ~exist(figsDir, 'dir'); mkdir(figsDir); end
cmap = colorcet('L6');
%cmap = cmap(end:-1:1,:);
cmap(1,:) = [.97 .97 .97];
epsilon = 0.01;

%% Figure 7, leftmost column: full real-world database (3 projections)
close all
plotMBSpace(Sim, cmap)

%% Figure 7: three-primary displays (CRT, LCD, Display++)
plotDistortedColourMaps(CRT,Sim,'crt','fig7', cmap, epsilon)
plotDistortedColourMaps(LCD,Sim,'lcd','fig7', cmap, epsilon)
plotDistortedColourMaps(DP ,Sim,'dp' ,'fig7', cmap, epsilon)

%% Figure 8: five-primary displays (MPHDR, Man, nb5p, bb5p, NZ)
plotDistortedColourMaps(MPHDR,Sim,'MPHDR','fig8', cmap, epsilon)
plotDistortedColourMaps(Man  ,Sim,'Man'  ,'fig8', cmap, epsilon)
plotDistortedColourMaps(nb5p ,Sim,'nb5p' ,'fig8', cmap, epsilon)
plotDistortedColourMaps(bb5p ,Sim,'bb5p' ,'fig8', cmap, epsilon)
plotDistortedColourMaps(NZ   ,Sim,'NZ'   ,'fig8', cmap, epsilon)

%%
clear all;

%% functions

function plotMBSpace(Sim, cmap)

figp = load_data().fig_parameters;figsDir = fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))), 'figs');
if ~exist(figsDir, 'dir'); mkdir(figsDir); end

lStep = 0.003;
sStep = 0.001;
mbl = 0.6:lStep:0.9;
mbs = 0:sStep:0.1;

mbFreq = zeros(100,100);

for i=1:100
    for j=1:100
        mbFreq(i,j)=sum((Sim.mb(2,:)>mbs(i) & Sim.mb(2,:)<(mbs(i)+sStep) & Sim.mb(1,:)>mbl(j) & Sim.mb(1,:)<(mbl(j)+lStep)),'omitnan'); 
    end
end

mbFreq(isnan(mbFreq))=0;

%%
fig = figure;hold on;ax = gca;
h=imagesc(mbFreq);
fig.Units = 'centimeters';fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/4*0.95,figp.twocolumn/4*0.95];
hold on;
set(gca,'YDir','normal');
colormap(cmap);

%c = colorbar();
c.Label.String = 'Frequency';
c.LineWidth = 1;

caxis([0,80]);
xticks([1,33,66,99]);yticks([1,50,100]);
xticklabels([0.6,0.7,0.8,0.9]);yticklabels([0,0.05,0.1]);
xlim([0,100]);ylim([0,100]);
ax.XTickLabel = {'0.60','0.70','0.80','0.90'};ax.YTickLabel = {'0.00','0.05','0.10'};

ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
ax.FontSize = figp.fontsize;
ax.LineWidth = 0.5;
ax.Position = [0.7 0.8 3.2 3.2];


axis square;grid on;box off;
drawnow;
exportgraphics(ax, fullfile(figsDir,'fig7_LvsS_all.pdf'),'ContentType','image','Resolution',600);

%% second projection
lStep = 0.003;
iStep = 0.0025;
mbl = 0.6:0.003:0.9;
mbi = 0:0.0025:0.25;

for i=1:100
    for j=1:100
        mbFreq2(i,j)=sum((Sim.mb(3,:)>mbi(i) & Sim.mb(3,:)<(mbi(i)+iStep) & Sim.mb(1,:)>mbl(j) & Sim.mb(1,:)<(mbl(j)+lStep)),'omitnan'); 
    end
end

mbFreq2(isnan(mbFreq2))=0;

%%
fig = figure;hold on;ax = gca;
h=imagesc(mbFreq2);hold on;
fig.Units = 'centimeters';fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/4*0.95,figp.twocolumn/4*0.95];
set(gca,'YDir','normal');
colormap(cmap);
%c = colorbar();
c.Label.String = 'Frequency';
c.LineWidth = 0.5;

caxis([0,80]);
xticks([1,33,66,99]);yticks([1,40,80]);
xticklabels([0.6,0.7,0.8,0.9]);yticklabels([0,0.1,0.2]);
xlim([0,100]);ylim([0,100]);
ax.XTickLabel = {'0.60','0.70','0.80','0.90'};ax.YTickLabel = {'0.00','0.10','0.20'};

ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
ax.FontSize = figp.fontsize;
ax.LineWidth = 0.5;
ax.Position = [0.7 0.8 3.2 3.2];


drawnow;
exportgraphics(ax, fullfile(figsDir,'fig7_LvsI_all.pdf'),'ContentType','image','Resolution',600);

%% third projection
sStep = 0.001;
iStep = 0.0025;
mbs = 0:sStep:0.1;
mbi = 0:iStep:0.25;
mbFreq3 = zeros(100,100);
for i=1:100
    for j=1:100
        mbFreq3(i,j)=sum((Sim.mb(2,:)>mbs(i) & Sim.mb(2,:)<(mbs(i)+sStep) & Sim.mb(3,:)>mbi(j) & Sim.mb(3,:)<(mbi(j)+iStep)),'omitnan'); 
    end
end

mbFreq3(isnan(mbFreq3))=0;

%%
fig = figure;hold on;ax = gca;
h=imagesc(mbFreq3);
fig.Units = 'centimeters';fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/4*0.95,figp.twocolumn/4*0.95];
hold on;
set(gca,'YDir','normal');
colormap(cmap);
%c = colorbar();
c.Label.String = 'Frequency';
c.LineWidth = 2;

caxis([0,80]);
xticks([1,40,80]);yticks([1,50,100]);
xticklabels([0,0.1,0.2]);yticklabels([0,0.05,0.1]);
xlim([0,100]);ylim([0,100]);
ax.XTickLabel = {'0.00','0.10','0.20'};ax.YTickLabel = {'0.00','0.05','0.10'};

ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
ax.FontSize = figp.fontsize;
ax.LineWidth = 0.5;
ax.Position = [0.7 0.8 3.2 3.2];


drawnow;
exportgraphics(ax, fullfile(figsDir,'fig7_IvsS_all.pdf'),'ContentType','image','Resolution',600);
end

function plotDistortedColourMaps(disp, Sim, fignum, figpref, cmap, epsilon)
figp = load_data().fig_parameters;figsDir = fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))), 'figs');
if ~exist(figsDir, 'dir'); mkdir(figsDir); end

%columnN = 4; % 4 columns
%fsize = 3.2; % fsize
columnN = 5; % 4 columns
fsize = 2.4; 

% check if within 1% of error for each signal
withinTolerance = (disp.alphaReproduced+(disp.alphaReproduced*epsilon)) >= Sim.ss & (disp.alphaReproduced-(disp.alphaReproduced*epsilon)) <= Sim.ss; % to 1% tolerance
ifMatch = (sum(withinTolerance(:,:))==5); % reproduced for all five primaries
% check if within tolerance and reproducible
mbDistorted = disp.mbDistorted(:,ifMatch);

%%
lStep = 0.003;sStep = 0.001;
mbl = 0.6:lStep:0.9;mbs = 0:sStep:0.1;
disp1 = zeros(100,100);

for i=1:100
    for j=1:100
        disp1(i,j)=sum((mbDistorted(2,:)>mbs(i) & mbDistorted(2,:)<(mbs(i)+sStep) & mbDistorted(1,:)>mbl(j) & mbDistorted(1,:)<(mbl(j)+lStep)),'omitnan'); 
    end
end

disp1(isnan(disp1))=0;

%%
fig = figure;hold on;ax = gca;
h=imagesc(disp1);
fig.Units = 'centimeters';fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/columnN*0.95,figp.twocolumn/columnN*0.95];
hold on;
set(gca,'YDir','normal');
colormap(cmap);
%c = colorbar();
c.Label.String = 'Frequency';
c.LineWidth = 0.5;

caxis([0,55]);
xticks([1,33,66,99]);yticks([1,50,100]);
xticklabels([0.6,0.7,0.8,0.9]);yticklabels([0,0.05,0.1]);
xlim([0,100]);ylim([0,100]);
ax.XTickLabel = {'0.60','0.70','0.80','0.90'};ax.YTickLabel = {'0.00','0.05','0.10'};

ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
ax.FontSize = figp.fontsize;
ax.LineWidth = 0.5;


ax.Position = [0.7 0.8 fsize fsize];

axis square;grid on;box off;

drawnow;
exportgraphics(ax, [fullfile(figsDir,[figpref '_LvsS_']),fignum,'.pdf'],'ContentType','image','Resolution',600);

%% second projection
lStep = 0.003;mbl = 0.6:lStep:0.9;
iStep = 0.0025;mbi = 0:iStep:0.25;
disp2 = zeros(100,100);

for i=1:100
    for j=1:100
        disp2(i,j)=sum((mbDistorted(3,:)>mbi(i) & mbDistorted(3,:)<(mbi(i)+iStep) & mbDistorted(1,:)>mbl(j) & mbDistorted(1,:)<(mbl(j)+lStep)),'omitnan'); 
    end
end

disp2(isnan(disp2))=0;

%%
fig = figure;hold on;ax = gca;
h=imagesc(disp2);
fig.Units = 'centimeters';fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/columnN*0.95,figp.twocolumn/columnN*0.95];
hold on;
set(gca,'YDir','normal');
colormap(cmap);
%c = colorbar();
c.Label.String = 'Frequency';c.LineWidth = 0.5;caxis([0,55]);

caxis([0,55]);
xticks([1,33,66,99]);yticks([1,40,80]);
xticklabels([0.6,0.7,0.8,0.9]);yticklabels([0,0.1,0.2]);
xlim([0,100]);ylim([0,100]);
ax.XTickLabel = {'0.60','0.70','0.80','0.90'};ax.YTickLabel = {'0.00','0.10','0.20'};

ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
ax.FontSize = figp.fontsize;
ax.LineWidth = 0.5;


ax.Position = [0.7 0.8 fsize fsize];

axis square;grid on;box off;
drawnow;
exportgraphics(ax, [fullfile(figsDir,[figpref '_LvsI_']),fignum,'.pdf'],'ContentType','image','Resolution',600);

%% third projection
sStep = 0.001;mbs = 0:sStep:0.1;
iStep = 0.0025;mbi = 0:iStep:0.25;
disp3 = zeros(100,100);

for i=1:100
    for j=1:100
        disp3(i,j)=sum((disp.mbDistorted(3,ifMatch)>mbi(j) & disp.mbDistorted(3,ifMatch)<(mbi(j)+iStep) & disp.mbDistorted(2,ifMatch)>mbs(i) & disp.mbDistorted(2,ifMatch)<(mbs(i)+sStep)),'omitnan'); 
    end
end

disp3(isnan(disp3))=0;

%%
fig = figure;hold on;ax = gca;
h=imagesc(disp3);
fig.Units = 'centimeters';fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/columnN*0.95,figp.twocolumn/columnN*0.95];
hold on;
set(gca,'YDir','normal');
colormap(cmap);
%c = colorbar();
c.Label.String = 'Frequency';c.LineWidth = 2;
caxis([0,55]);

xticks([1,40,80]);yticks([1,50,100]);
xticklabels([0,0.1,0.2]);yticklabels([0,0.05,0.1]);
xlim([0,100]);ylim([0,100]);
ax.XTickLabel = {'0.00','0.10','0.20'};ax.YTickLabel = {'0.00','0.05','0.10'};

ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
ax.FontSize = figp.fontsize;
ax.LineWidth = 0.5;


ax.Position = [0.7 0.8 fsize fsize];

axis square;grid on;box off;
drawnow;
exportgraphics(ax, [fullfile(figsDir,[figpref '_IvsS_']),fignum,'.pdf'],'ContentType','image','Resolution',600);
end