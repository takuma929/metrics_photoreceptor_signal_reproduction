% plot Figure 3 of paper
% plots primaries of displays used
% First developed by ACS, modified by TM.

%% load data
clear all;
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

clc;
     
%% load relevant data file
% Canonical condition for the main-text figures: TM30 dataset, continuous
% (Inf-bit) weights. Resolved relative to this script so it works from any CWD.
metricsFile = fullfile(projectRoot, 'results', 'photosimMetrics_ReproduceLMS_Main_Inf.mat');
load(metricsFile);
figp = load_data().fig_parameters;figsDir = fullfile(projectRoot, 'figs');
if ~exist(figsDir, 'dir'); mkdir(figsDir); end
dataDir = fullfile(projectRoot, 'data');
vscale = 0.75;

%% plot Fig3a - CRT primaries
fig = figure;hold on;ax = gca;
plotDisplayPrimaries(CRT)

yticks([])
ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
ax.FontSize = figp.fontsize;
ax.LineWidth = 0.5;
ax.Position = [0.7 0.75 4.6 4.6*vscale];

fig.Units = 'centimeters';fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/3*0.95,figp.twocolumn/3*0.95*vscale];

    drawnow;
    exportgraphics(fig, fullfile(figsDir,'fig3a.pdf'),'ContentType','vector');

%% plot Fig3b -  Dell LCD primaries
fig = figure;hold on;ax = gca;
plotDisplayPrimaries(LCD)
yticks([])
ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
ax.FontSize = figp.fontsize;
ax.LineWidth = 0.5;
ax.Position = [0.7 0.75 4.6 4.6*vscale];

fig.Units = 'centimeters';fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/3*0.95,figp.twocolumn/3*0.95*vscale];

    drawnow;
    exportgraphics(fig, fullfile(figsDir,'fig3b.pdf'),'ContentType','vector');

%% plot Fig3c - Display++ primaries
fig = figure;hold on;ax = gca;
plotDisplayPrimaries(DP)
yticks([])
ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
ax.FontSize = figp.fontsize;
ax.LineWidth = 0.5;
ax.Position = [0.7 0.75 4.6 4.6*vscale];

fig.Units = 'centimeters';fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/3*0.95,figp.twocolumn/3*0.95*vscale];

    drawnow;
    exportgraphics(fig, fullfile(figsDir,'fig3c.pdf'),'ContentType','vector');

%% plot Fig3d - Broadband five primary primaries
fig = figure;hold on;ax = gca;
plotDisplayPrimariesMultiPrimary(nb5p)
yticks([])
ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
ax.FontSize = figp.fontsize;
ax.LineWidth = 0.5;
ax.Position = [0.7 0.75 4.6 4.6*vscale];

fig.Units = 'centimeters';fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/3*0.95,figp.twocolumn/3*0.95*vscale];

    drawnow;
    exportgraphics(fig, fullfile(figsDir,'fig3d.pdf'),'ContentType','vector');

%% plot Fig3e - Narrowband five primary primaries
fig = figure;hold on;ax = gca;
plotDisplayPrimariesMultiPrimary(bb5p)
yticks([])
ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
ax.FontSize = figp.fontsize;
ax.LineWidth = 0.5;
ax.Position = [0.7 0.75 4.6 4.6*vscale];

fig.Units = 'centimeters';fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/3*0.95,figp.twocolumn/3*0.95*vscale];

    drawnow;
    exportgraphics(fig, fullfile(figsDir,'fig3e.pdf'),'ContentType','vector');

%% load relevant data from the consolidated store
data = load_data();
mphdrRGBCMY = data.mphdr.rgbcmy;
wls = data.mphdr.wl';
manchester_primaries = data.manchester.primaries;
manchester_wls = data.manchester.wl;
nz_primaries = data.nugent_zele.primaries;
nz_wls = data.nugent_zele.wl;
load(metricsFile);

%% plot primaries for Manchester display
fig = figure;hold on;ax = gca;
hold on;
h(1)=plot(manchester_wls,manchester_primaries(:,5),'Color',[0.5,0,0],'LineWidth',.5);
h(2)=plot(manchester_wls,manchester_primaries(:,3),'Color',[0,0.5,0],'LineWidth',.5);
h(3)=plot(manchester_wls,manchester_primaries(:,2),'Color',[0,0,0.5],'LineWidth',.5);
h(3)=plot(manchester_wls,manchester_primaries(:,1),'Color',[0.4940,0.1840,0.5560],'LineWidth',.5);
h(3)=plot(manchester_wls,manchester_primaries(:,4),'Color',[0.9290,0.6940,0.1250],'LineWidth',.5);

x = manchester_wls(2:end);
y=manchester_primaries(2:end,5);
fill([x fliplr(x)], [y zeros(size(y))], [0.5,0,0], ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');
y=manchester_primaries(2:end,3);
fill([x fliplr(x)], [y zeros(size(y))], [0,0.5,0], ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');
y=manchester_primaries(2:end,2);
fill([x fliplr(x)], [y zeros(size(y))], [0,0,0.5], ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');
y=manchester_primaries(2:end,1);
fill([x fliplr(x)], [y zeros(size(y))], [0.4940,0.1840,0.5560], ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');
y=manchester_primaries(2:end,4);
fill([x fliplr(x)], [y zeros(size(y))], [0.9290,0.6940,0.1250], ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');

yticks([])
xlabel('Wavelength (nm)');
ylabel('Relative Power');
yticklabels({});
xticks([400,500,600,700,780]);
xticklabels({'400','500','600','700','780'});
xlim([390,780]);
grid on;

ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
ax.FontSize = figp.fontsize;
ax.LineWidth = 0.5;
ax.Position = [0.7 0.75 4.6 4.6*vscale];

fig.Units = 'centimeters';fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/3*0.95,figp.twocolumn/3*0.95*vscale];
    drawnow;
    exportgraphics(fig, fullfile(figsDir,'fig3f.pdf'),'ContentType','vector');

%% plot primaries for MPHDR
fig = figure;hold on;ax = gca;
hold on;
h(1)=plot(wls,mphdrRGBCMY(:,1),'Color',[0.5,0,0],'LineWidth',.5);
h(2)=plot(wls,mphdrRGBCMY(:,4),'Color',[0.8500, 0.3250, 0.0980],'LineWidth',.5);
h(3)=plot(wls,mphdrRGBCMY(:,6),'Color',[0,0,0.5],'LineWidth',.5);
h(3)=plot(wls,mphdrRGBCMY(:,3),'Color',[0.4940,0.1840,0.5560],'LineWidth',.5);
h(3)=plot(wls,mphdrRGBCMY(:,2),'Color',[0.9290,0.6940,0.1250],'LineWidth',.5);
h(3)=plot(wls,mphdrRGBCMY(:,5),'Color',[0,0.5,0],'LineWidth',.5);

x = wls';
y=mphdrRGBCMY(:,1);
fill([x fliplr(x)], [y zeros(size(y))], [0.5,0,0], ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');
y=mphdrRGBCMY(:,4);
fill([x fliplr(x)], [y zeros(size(y))], [0.8500, 0.3250, 0.0980], ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');
y=mphdrRGBCMY(:,6);
fill([x fliplr(x)], [y zeros(size(y))], [0,0,0.5], ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');
y=mphdrRGBCMY(:,3);
fill([x fliplr(x)], [y zeros(size(y))], [0.4940,0.1840,0.5560], ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');
y=mphdrRGBCMY(:,2);
fill([x fliplr(x)], [y zeros(size(y))], [0.9290,0.6940,0.1250], ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');
y=mphdrRGBCMY(:,5);
fill([x fliplr(x)], [y zeros(size(y))], [0,0.5,0], ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');

yticks([])
xlabel('Wavelength (nm)');
ylabel('Relative Power');
yticklabels({});
xticks([400,500,600,700,780]);
xticklabels({'400','500','600','700','780'});
xlim([390,780]);
grid on;

ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
ax.FontSize = figp.fontsize;
ax.LineWidth = 0.5;
ax.Position = [0.7 0.75 4.6 4.6*vscale];

fig.Units = 'centimeters';fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/3*0.95,figp.twocolumn/3*0.95*vscale];
    drawnow;
    exportgraphics(fig, fullfile(figsDir,'fig3g.pdf'),'ContentType','vector');

%% plot primaries for Nugent Zele display
fig = figure;hold on;ax = gca;
hold on;
x = nz_wls;
h(1)=plot(nz_wls,nz_primaries(:,5),'Color',[0.5,0,0],'LineWidth',0.5);
h(2)=plot(nz_wls,nz_primaries(:,3),'Color',[0,0.5,0],'LineWidth',0.5);
h(3)=plot(nz_wls,nz_primaries(:,2),'Color',[0,0,0.5],'LineWidth',0.5);
h(3)=plot(nz_wls,nz_primaries(:,1),'Color',[0.4940,0.1840,0.5560],'LineWidth',0.5);
h(3)=plot(nz_wls,nz_primaries(:,4),'Color',[0.9290,0.6940,0.1250],'LineWidth',0.5);

y=nz_primaries(:,5);
fill([x fliplr(x)], [y zeros(size(y))], [0.5,0,0], ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');
y=nz_primaries(:,3);
fill([x fliplr(x)], [y zeros(size(y))], [0,0.5,0], ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');
y=nz_primaries(:,2);
fill([x fliplr(x)], [y zeros(size(y))], [0,0,0.5], ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');
y=nz_primaries(:,1);
fill([x fliplr(x)], [y zeros(size(y))], [0.4940,0.1840,0.5560], ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');
y=nz_primaries(:,4);
fill([x fliplr(x)], [y zeros(size(y))], [0.9290,0.6940,0.1250], ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');

yticks([])
xlabel('Wavelength (nm)');
ylabel('Relative Power');
yticklabels({});
xticks([400,500,600,700,780]);
xticklabels({'400','500','600','700','780'});
xlim([390,780]);
grid on;

ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
ax.FontSize = figp.fontsize;
ax.LineWidth = 0.5;
ax.Position = [0.7 0.75 4.6 4.6*vscale];

fig.Units = 'centimeters';fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/3*0.95,figp.twocolumn/3*0.95*vscale];

    drawnow;
    exportgraphics(fig, fullfile(figsDir,'fig3h.pdf'),'ContentType','vector');

clear all;close all;

%% functions

function plotDisplayPrimaries(display)

hold on;
x = (390:780)';
h(1)=plot(x,display.spd(:,1),'Color',[0.5,0,0],'LineWidth',0.5);
h(2)=plot(x,display.spd(:,2),'Color',[0,0.5,0],'LineWidth',0.5);
h(3)=plot(x,display.spd(:,3),'Color',[0,0,0.5],'LineWidth',0.5);

y=display.spd(:,1);
fill([x fliplr(x)], [y zeros(size(y))], [0.5,0,0], ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');
y=display.spd(:,2);
fill([x fliplr(x)], [y zeros(size(y))], [0,0.5,0], ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');
y=display.spd(:,3);
fill([x fliplr(x)], [y zeros(size(y))], [0,0,0.5], ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');

xlabel('Wavelength (nm)');
ylabel('Relative Power');
yticklabels({});
xticks([400,500,600,700,780]);
xticklabels({'400','500','600','700','780'});
xlim([390,780]);
grid on;

end

function plotDisplayPrimariesMultiPrimary(display)

hold on;
x = (390:780)';
h(1)=plot(x,display.spd(:,5),'Color',[0.5,0,0],'LineWidth',.5);
h(2)=plot(x,display.spd(:,3),'Color',[0,0.5,0],'LineWidth',.5);
h(3)=plot(x,display.spd(:,2),'Color',[0,0,0.5],'LineWidth',.5);
h(3)=plot(x,display.spd(:,1),'Color',[0.4940,0.1840,0.5560],'LineWidth',.5);
h(3)=plot(x,display.spd(:,4),'Color',[0.9290,0.6940,0.1250],'LineWidth',.5);

y=display.spd(:,5);
fill([x fliplr(x)], [y zeros(size(y))], [0.5,0,0], ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');
y=display.spd(:,3);
fill([x fliplr(x)], [y zeros(size(y))], [0,0.5,0], ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');
y=display.spd(:,2);
fill([x fliplr(x)], [y zeros(size(y))], [0,0,0.5], ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');
y=display.spd(:,1);
fill([x fliplr(x)], [y zeros(size(y))], [0.4940,0.1840,0.5560], ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');
y=display.spd(:,4);
fill([x fliplr(x)], [y zeros(size(y))], [0.9290,0.6940,0.1250], ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');

xlabel('Wavelength (nm)');
ylabel('Relative Power');
yticklabels({});
xticks([400,500,600,700,780]);
xticklabels({'400','500','600','700','780'});
xlim([390,780]);
grid on;

end