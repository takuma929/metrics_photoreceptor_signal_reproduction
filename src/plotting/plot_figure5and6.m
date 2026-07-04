% plot Figures 5 and 6 of the paper
% First developed by ACS, modified by TM.
%
% Figure 5 - reproduced rod (A_R') and melanopsin (A_I') signals plotted
%   against the real-world signals, for the three three-primary displays
%   (CRT, LCD, Display++). 6 panels fig5{a,b,c}{i,ii}: a=CRT, b=LCD, c=DP; i=rod, ii=mel.
%
% Figure 6 - PSDM analysis. Following the manuscript, panel 6a = rod (A_R) and
%   6b = melanopsin (A_I); each shows boxplots of the per-spectrum PSDM (upper)
%   and the mean PSDM over the CIE 1931 xy chromaticity diagram (lower), for
%   CRT, LCD, Display++. 12 files fig6{a,b}_{box,xy}_{CRT,LCD,DP}.
%
% Every panel is its own %% section, so "Run Section" regenerates a single
% panel once the "load data" section has been run. Panels that mix
% transparency / imagesc are written as high-resolution raster PDFs
% (ContentType image) to avoid the vector-export deadlock in the MATLAB GUI.

%% load data
close all;clearvars;clc;

% --- project paths (location-independent) ---
projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(fullfile(projectRoot, 'data'));
addpath(fullfile(projectRoot, 'results'));
dataDir = fullfile(projectRoot, 'data');
resDir  = fullfile(projectRoot, 'results');
figsDir = fullfile(projectRoot, 'figs');
if ~exist(figsDir, 'dir'); mkdir(figsDir); end

% Canonical condition for the main-text figures: continuous (Inf-bit) weights.
metricsFile = fullfile(projectRoot, 'results', 'photosimMetrics_ReproduceLMS_Main_Inf.mat');
load(metricsFile);              % provides Sim and the display structs CRT/LCD/DP/...
figp = load_data().fig_parameters;

% display marker colours and photoreceptor indices
CRTcol = [0,0,0];
LCDcol = [0.2,0.2,0.2];
DPcol  = [0.6,0.6,0.6];
ROD = 4;   % A_R
MEL = 5;   % A_I

% =====================================================================
%  Figure 5 - reproduced vs real-world rod / melanopsin signals (scatter)
% =====================================================================

%% Fig 5 - CRT rod  (fig5ai)
fig = figure;hold on;ax = gca;
plotDistortions(CRT,ROD,Sim,CRTcol,'A_R','A_R''',fig,ax);
drawnow;
exportgraphics(fig, fullfile(figsDir,'fig5ai.pdf'),'ContentType','image','Resolution',600);

%% Fig 5 - CRT melanopsin  (fig5aii)
fig = figure;hold on;ax = gca;
plotDistortions(CRT,MEL,Sim,CRTcol,'A_I','A_I''',fig,ax);
drawnow;
exportgraphics(fig, fullfile(figsDir,'fig5aii.pdf'),'ContentType','image','Resolution',600);

%% Fig 5 - LCD rod  (fig5bi)
fig = figure;hold on;ax = gca;
plotDistortions(LCD,ROD,Sim,LCDcol,'A_R','A_R''',fig,ax);
drawnow;
exportgraphics(fig, fullfile(figsDir,'fig5bi.pdf'),'ContentType','image','Resolution',600);

%% Fig 5 - LCD melanopsin  (fig5bii)
fig = figure;hold on;ax = gca;
plotDistortions(LCD,MEL,Sim,LCDcol,'A_I','A_I''',fig,ax);
drawnow;
exportgraphics(fig, fullfile(figsDir,'fig5bii.pdf'),'ContentType','image','Resolution',600);

%% Fig 5 - Display++ rod  (fig5ci)
fig = figure;hold on;ax = gca;
plotDistortions(DP,ROD,Sim,DPcol,'A_R','A_R''',fig,ax);
drawnow;
exportgraphics(fig, fullfile(figsDir,'fig5ci.pdf'),'ContentType','image','Resolution',600);

%% Fig 5 - Display++ melanopsin  (fig5cii)
fig = figure;hold on;ax = gca;
plotDistortions(DP,MEL,Sim,DPcol,'A_I','A_I''',fig,ax);
drawnow;
exportgraphics(fig, fullfile(figsDir,'fig5cii.pdf'),'ContentType','image','Resolution',600);

% =====================================================================
%  Figure 6a - Rod (A_R) PSDM   |  Figure 6b - Melanopsin (A_I) PSDM
%  Panel letter follows the manuscript: 6a = rod, 6b = melanopsin. Each panel
%  = boxplots (upper) + mean-PSDM xy chromaticity maps (lower), CRT/LCD/DP.
% =====================================================================

%% Fig 6 box-plot medians header
fprintf('\n=== Figure 6 box-plot medians [PSDM %%] (add to the panels) ===\n');

% ---- Figure 6a : rod (A_R) ----

%% Fig 6a - CRT rod boxplot  (fig6a_box_CRT)
fig = figure;hold on;ax = gca;
plotBoxplots(CRT,ROD,'PSDM_R [%]',fig,ax);
drawnow;
exportgraphics(fig, fullfile(figsDir,'fig6a_box_CRT.pdf'),'ContentType','image','Resolution',600);
fprintf('  fig6a_box_CRT  CRT rod (PSDM_R): median = %+.2f %%\n', median(CRT.distortionMetric(ROD,:),'omitnan'));

%% Fig 6a - LCD rod boxplot  (fig6a_box_LCD)
fig = figure;hold on;ax = gca;
plotBoxplots(LCD,ROD,'PSDM_R [%]',fig,ax);
drawnow;
exportgraphics(fig, fullfile(figsDir,'fig6a_box_LCD.pdf'),'ContentType','image','Resolution',600);
fprintf('  fig6a_box_LCD  LCD rod (PSDM_R): median = %+.2f %%\n', median(LCD.distortionMetric(ROD,:),'omitnan'));

%% Fig 6a - DP rod boxplot  (fig6a_box_DP)
fig = figure;hold on;ax = gca;
plotBoxplots(DP,ROD,'PSDM_R [%]',fig,ax);
drawnow;
exportgraphics(fig, fullfile(figsDir,'fig6a_box_DP.pdf'),'ContentType','image','Resolution',600);
fprintf('  fig6a_box_DP   DP  rod (PSDM_R): median = %+.2f %%\n', median(DP.distortionMetric(ROD,:),'omitnan'));

%% Fig 6a - CRT rod xy map  (fig6a_xy_CRT)
fig = figure;hold on;ax = gca;
plotDistortionsOverxy(CRT,Sim,ROD,'PSDM_R [%]',fig,ax);
drawnow;
exportgraphics(fig, fullfile(figsDir,'fig6a_xy_CRT.pdf'),'ContentType','image','Resolution',600);

%% Fig 6a - LCD rod xy map  (fig6a_xy_LCD)
fig = figure;hold on;ax = gca;
plotDistortionsOverxy(LCD,Sim,ROD,'PSDM_R [%]',fig,ax);
drawnow;
exportgraphics(fig, fullfile(figsDir,'fig6a_xy_LCD.pdf'),'ContentType','image','Resolution',600);

%% Fig 6a - DP rod xy map  (fig6a_xy_DP)
fig = figure;hold on;ax = gca;
plotDistortionsOverxy(DP,Sim,ROD,'PSDM_R [%]',fig,ax);
drawnow;
exportgraphics(fig, fullfile(figsDir,'fig6a_xy_DP.pdf'),'ContentType','image','Resolution',600);

% ---- Figure 6b : melanopsin (A_I) ----

%% Fig 6b - CRT mel boxplot  (fig6b_box_CRT)
fig = figure;hold on;ax = gca;
plotBoxplots(CRT,MEL,'PSDM_I [%]',fig,ax);
drawnow;
exportgraphics(fig, fullfile(figsDir,'fig6b_box_CRT.pdf'),'ContentType','image','Resolution',600);
fprintf('  fig6b_box_CRT  CRT mel (PSDM_I): median = %+.2f %%\n', median(CRT.distortionMetric(MEL,:),'omitnan'));

%% Fig 6b - LCD mel boxplot  (fig6b_box_LCD)
fig = figure;hold on;ax = gca;
plotBoxplots(LCD,MEL,'PSDM_I [%]',fig,ax);
drawnow;
exportgraphics(fig, fullfile(figsDir,'fig6b_box_LCD.pdf'),'ContentType','image','Resolution',600);
fprintf('  fig6b_box_LCD  LCD mel (PSDM_I): median = %+.2f %%\n', median(LCD.distortionMetric(MEL,:),'omitnan'));

%% Fig 6b - DP mel boxplot  (fig6b_box_DP)
fig = figure;hold on;ax = gca;
plotBoxplots(DP,MEL,'PSDM_I [%]',fig,ax);
drawnow;
exportgraphics(fig, fullfile(figsDir,'fig6b_box_DP.pdf'),'ContentType','image','Resolution',600);
fprintf('  fig6b_box_DP   DP  mel (PSDM_I): median = %+.2f %%\n', median(DP.distortionMetric(MEL,:),'omitnan'));

%% Fig 6b - CRT mel xy map  (fig6b_xy_CRT)
fig = figure;hold on;ax = gca;
plotDistortionsOverxy(CRT,Sim,MEL,'PSDM_I [%]',fig,ax);
drawnow;
exportgraphics(fig, fullfile(figsDir,'fig6b_xy_CRT.pdf'),'ContentType','image','Resolution',600);

%% Fig 6b - LCD mel xy map  (fig6b_xy_LCD)
fig = figure;hold on;ax = gca;
plotDistortionsOverxy(LCD,Sim,MEL,'PSDM_I [%]',fig,ax);
drawnow;
exportgraphics(fig, fullfile(figsDir,'fig6b_xy_LCD.pdf'),'ContentType','image','Resolution',600);

%% Fig 6b - DP mel xy map  (fig6b_xy_DP)
fig = figure;hold on;ax = gca;
plotDistortionsOverxy(DP,Sim,MEL,'PSDM_I [%]',fig,ax);
drawnow;
exportgraphics(fig, fullfile(figsDir,'fig6b_xy_DP.pdf'),'ContentType','image','Resolution',600);

%% functions

% scatter of reproduced vs real-world signal for one photoreceptor
function h = plotDistortions(display,d,Sim,col,xlab,ylab,fig,ax)
    figp = load_data().fig_parameters;

    % Fix the figure geometry BEFORE drawing so exportgraphics never captures
    % a pre-resize (default, oversized) layout. See plotBoxplots for details.
    fig.Units = 'centimeters';fig.Color = 'w';
    fig.InvertHardcopy = 'off';
    fig.PaperPosition   = [0,10,8.45,8.45];
    fig.Position = [10,10,figp.twocolumn/4*0.95,figp.twocolumn/4*0.95];

    h=scatter(Sim.ss(d,:),display.alphaReproduced(d,:),20,'wo','filled','MarkerEdgeColor',[0 0 0],'LineWidth',0.3);
    hold on;
    plot([-1:1],[-1:1],'Color',[0.8,0,0.8],'LineWidth',1);
    xlim([-0.005,0.07]);
    ylim([-0.005,0.07]);
    xlabel(xlab);
    ylabel(ylab);
    xticklabels({});
    yticklabels({});
    axis square
    grid on;
    box on;
    ax.FontName = 'Arial';
    ax.Units = 'centimeters';
    ax.Color = [.97 .97 .97];
    ax.XColor = 'k';ax.YColor = 'k';
    ax.FontSize = figp.fontsize;
    ax.LineWidth = 0.5;
    ax.Position = [0.65 0.6 3.4 3.4];

    grid on;box off;
end

% horizontal boxplot of the per-spectrum PSDM distribution
function h = plotBoxplots(display,d,lab,fig,ax)
figp = load_data().fig_parameters;

% Fix the figure geometry BEFORE drawing. Resizing the figure *after* boxplot
% has drawn triggers a deferred re-layout (boxplot uses internal listeners)
% that exportgraphics can capture before it settles -> giant/inconsistent PDF.
fig.Units = 'centimeters';fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/4*0.95,figp.twocolumn/8*0.95];

h=boxplot(display.distortionMetric(d,:),'Orientation','horizontal','Colors','k','Symbol','k.');
set(h,{'linew'},{0.5});
yticklabels({});
xlim([-100,100]);
xlabel(lab);
ylim([0.9,1.1]);
ylabel('');

xticks([-100 -50 0 50 100]);yticks([])
ax.XTickLabel = {'-100','-50','0','50','100'};ax.YTickLabel = {};

ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
ax.FontSize = figp.fontsize;
ax.LineWidth = 0.5;
ax.Position = [0.5 1.1 3.6 1.0];

grid on;box on;
end

% mean PSDM over a 100x100 grid of the CIE 1931 xy chromaticity diagram
function h = plotDistortionsOverxy(display,Sim,d,lab,fig,ax)
figp = load_data().fig_parameters;

% Fix the figure geometry BEFORE drawing so exportgraphics never captures a
% pre-resize (default, oversized) layout. See plotBoxplots for details.
fig.Units = 'centimeters';fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/4*0.95,figp.twocolumn/4*0.95];

xStep=0.01;
yStep=0.01;
x=0:0.01:0.99; y = 0:0.01:0.99;
for i=1:100
    for j=1:100
        xyDistortions(i,j)=mean(display.distortionMetric(d, Sim.xyY(1,:)>x(i) & Sim.xyY(1,:)<x(i)+xStep & Sim.xyY(2,:)>y(j) & Sim.xyY(2,:)<y(j)+yStep));
    end
end
xyDistortions(isnan(xyDistortions)==1)=0;
h=imagesc(xyDistortions');
hold on;
plot(0.3128*100,0.3290*100,'k+','LineWidth',1,'MarkerSize',5);
set(gca,'YDir','normal');
colormap(colorcet('D10'));

xlabel('CIE x');
ylabel('CIE y');
caxis([-40,40]);
xticks(1:10:100);
xticklabels(round(0:0.1:1,1));
yticks(1:10:100);
yticklabels(0:0.1:1);

axis square
box on;

ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
ax.FontSize = figp.fontsize;
ax.LineWidth = 0.5;
ax.Position = [0.95 0.9 3.2 3.2];

xlim([0,70]);ylim([0,70]);
xticks(0:20:60);yticks(0:20:60)
ax.XTickLabel = {'0.0','0.2','0.4','0.6'};ax.YTickLabel = {'0.0','0.2','0.4','0.6'};

grid on;box off;
end
