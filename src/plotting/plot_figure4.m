% plot Figure 4 of paper
% plots real-world and chromaticity reproduction plots
% First developed by ACS, modified by TM.

%% load data
clear all;close all;

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
figp = load_data().fig_parameters;% Canonical condition for the main-text figures: TM30 dataset, continuous
% (Inf-bit) weights. Resolved relative to this script so it works from any CWD.
metricsFile = fullfile(projectRoot, 'results', 'photosimMetrics_ReproduceLMS_Main_Inf.mat');
load(metricsFile);
figsDir = fullfile(projectRoot, 'figs');
if ~exist(figsDir, 'dir'); mkdir(figsDir); end
vscale = 0.75;
lwidth = 0.5;

%% plot fig4a - Chromaticity diagram % capture
fig = figure;hold on;ax = gca;
plot_chromaticity_alpha();
hold on;
scatter(Sim.xyY(1,:),Sim.xyY(2,:),4,'wo','filled','MarkerEdgeColor',[.3 .3 .3],'LineWidth',0.2);
scale = 0.9;
lstyle = '-';
h(1) = plotChromaticityReproduction(CRT,[0,0,0]*scale,lstyle);
h(2) = plotChromaticityReproduction(LCD,[0,0,0]*scale,'--');
h(3) = plotChromaticityReproduction(DP,[0.3,0.3,0.2]*scale,':');
h(4) = plotChromaticityReproduction(nb5p,[0,0.8,0.8]*scale,lstyle);
h(5) = plotChromaticityReproduction(bb5p,[0.5,0.5,0.8]*scale,lstyle);
h(6) = plotChromaticityReproduction(Man,[0.2,0.8,0.2]*scale,lstyle);
h(7) = plotChromaticityReproduction(MPHDR,[0.2,0.2,0.8]*scale,lstyle);
h(8) = plotChromaticityReproduction(NZ,[0.8,0.8,0.2]*scale,lstyle);

ax.XLim = [-0.05,0.85];ax.YLim = [-0.05,0.85];
xticks([0 0.2 0.4 0.6 0.8]);yticks([0 0.2 0.4 0.6 0.8])
ax.XTickLabel = {'0.0','0.20','0.40','0.60','0.80'};ax.YTickLabel = {'0.0','0.20','0.40','0.60','0.80'};
xlabel('CIE x'); ylabel('CIE y');
%legend(h,{'CRT','LCD','Display++','Narrowband 5P', 'Broadband 5P','Manchester VDU','RealVision MPHDR','Nugent-Zele'});
ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
%ax.FontSize = figp.fontsize+5; % for legend
ax.FontSize = figp.fontsize;
ax.LineWidth = 0.5;
ax.Position = [0.98 0.8 4.6 4.6];

fig.Units = 'centimeters';fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/3*0.95,figp.twocolumn/3*0.95];

grid on;box off;
%axis square
%exportgraphics(fig, fullfile(figsDir,'fig4a.pdf'),'ContentType','vector');
drawnow;
exportgraphics(fig, fullfile(figsDir,'fig4a.png'),'Resolution','600','ContentType','image');

%% plot fig4b - Reproduction of chromaticity bar graph
fig = figure;hold on;ax = gca;
b = bar([CRT.chromaticityReproductionMetric,LCD.chromaticityReproductionMetric,DP.chromaticityReproductionMetric,Man.chromaticityReproductionMetric,MPHDR.chromaticityReproductionMetric,NZ.chromaticityReproductionMetric,nb5p.chromaticityReproductionMetric,bb5p.chromaticityReproductionMetric],'BarWidth',0.6,'LineWidth',1.5,'EdgeColor','none');
b.FaceColor = 'flat';
b.CData(1,:) = [0.3,0,0.6];
b.CData(2,:) = [0.3,0,0.6];
b.CData(3,:) = [0.3,0,0.6];
b.CData(4,:) = [0.6,0,0.3];
b.CData(5,:) = [0.6,0,0.3];
b.CData(6,:) = [0.6,0,0.3];
b.CData(7,:) = [0.6,0,0.3];
b.CData(8,:) = [0.6,0,0.3];

xticklabels({'CRT','Dell LCD','Display++','Manchester VDU','Realvision MPHDR', 'Nugent-Zele', 'NB 5P', 'BB 5P'});
xlim([0.5,8.5]);
xticks(1:8);yticks(0:20:100);
ax.YTickLabel = {'0','20','40','60','80','100'};
xtickangle(45);
ylabel('Chromaticity Reproduction [%]');
ylim([0,104]);

ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
ax.FontSize = figp.fontsize;
ax.LineWidth = 0.5;
ax.Position = [0.98 2.1 3.2 3.8];

fig.Units = 'centimeters';fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/4*0.95,figp.twocolumn/2.8*0.95];
grid on;
ax.XGrid = 'off';

	drawnow;
	exportgraphics(fig, fullfile(figsDir,'fig4b.pdf'),'ContentType','vector');

%% plot fig4c - Reproduction of full photoreceptor signals bar graph
fig = figure;hold on;ax = gca;
data = [CRT.realworldReproductionMetric,LCD.realworldReproductionMetric,DP.realworldReproductionMetric,Man.realworldReproductionMetric,MPHDR.realworldReproductionMetric,NZ.realworldReproductionMetric,nb5p.realworldReproductionMetric,bb5p.realworldReproductionMetric];
data'
b = bar(data,'BarWidth',0.6,'LineWidth',1.5,'EdgeColor','none');
b.FaceColor= 'flat';
b.CData(1,:) = [0.3,0,0.6];
b.CData(2,:) = [0.3,0,0.6];
b.CData(3,:) = [0.3,0,0.6];
b.CData(4,:) = [0.6,0,0.3];
b.CData(5,:) = [0.6,0,0.3];
b.CData(6,:) = [0.6,0,0.3];
b.CData(7,:) = [0.6,0,0.3];
b.CData(8,:) = [0.6,0,0.3];
xticklabels({'CRT','Dell LCD','Display++','Manchester VDU','Realvision MPHDR', 'Nugent-Zele', 'NB 5P', 'BB 5P'});
xticks(1:8);yticks(0:20:100);
ax.YTickLabel = {'0','20','40','60','80','100'};
xlim([0.5,8.5]);
xtickangle(45);

ylim([0,104]);

xlim([0.5,8.5]);
xticks(1:8);yticks(0:20:100);
ax.YTickLabel = {'0','20','40','60','80','100'};
xtickangle(45);
ylabel('PSRM [%]');
ylim([0,104]);

ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
ax.FontSize = figp.fontsize;
ax.LineWidth = 0.5;
ax.Position = [0.98 2.1 3.2 3.8];

fig.Units = 'centimeters';fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/4*0.95,figp.twocolumn/2.8*0.95];
grid on;
ax.XGrid = 'off';

	drawnow;
	exportgraphics(fig, fullfile(figsDir,'fig4c.pdf'),'ContentType','vector');

%%
close all

%% functions

function h = plotChromaticityReproduction(display,col,lstyle)
hold on;
h=plot(display.xyYMax(1,display.idx),display.xyYMax(2,display.idx),'Color',col,'LineWidth',.5,'LineStyle',lstyle);
end
