% plot Figure 2 of paper
% plots extension of MacLeod Boynton space for spectral and daylight locus
% First developed by ACS, modified by TM.
%
% Each of the three panels (a,b,c) is a full-range projection of the
% equal-luminance photoreceptor excitation space with the spectral locus
% (black, 25 nm crosses coloured by wavelength) and the daylight locus
% (blue, dots coloured by CCT). A matching zoom of the daylight locus is
% saved separately as fig2{a,b,c}_insert.pdf and dropped into each panel.
%
% The locus chromaticities are computed here from the CIES026 fundamentals
% (mb026: row 1 = S, 2 = M, 3 = L, 5 = melanopsin/I) so the row convention is
% explicit; earlier versions read SL.mb whose row order is not S,L,I.

%% load data
clear all;close all;clc;

% --- project paths (location-independent) ---
projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(fullfile(projectRoot, 'data'));
addpath(fullfile(projectRoot, 'results'));
dataDir = fullfile(projectRoot, 'data');
resDir  = fullfile(projectRoot, 'results');
figsDir = fullfile(projectRoot, 'figs');
if ~exist(figsDir, 'dir'); mkdir(figsDir); end

figp = load_data().fig_parameters;
vscale = 1;   % square chromaticity panels; 3 panels tile to two-column width

%% set up spectral locus (from CIES026 S,M,L,Rod,Mel fundamentals)
ss = get_cies026;
T_cies026 = ss(:,11:end);          % 390:1:780 nm (391 samples)
T_cies026(isnan(T_cies026)) = 0;

% MacLeod-Boynton scale factors (CVRL, Stockman & Sharpe 2000 10-deg): http://www.cvrl.org/
lScale = 0.69283932;
mScale = 0.34967567;
sScale = 0.05547858;

mb026(1,:) = T_cies026(1,:)*sScale;   % S
mb026(2,:) = T_cies026(2,:)*mScale;   % M
mb026(3,:) = T_cies026(3,:)*lScale;   % L
iScale     = 1./max(T_cies026(5,:)./(mb026(2,:)+mb026(3,:))); % so I/(L+M) peaks at 1
mb026(5,:) = T_cies026(5,:)*iScale;   % melanopsin (I)
mb026(isnan(mb026)) = 0;

% equal-luminance chromaticities of the spectral locus (390:1:780 nm)
LpM = mb026(2,:) + mb026(3,:);
SL_L = mb026(3,:)./LpM;   % L/(L+M)
SL_S = mb026(1,:)./LpM;   % S/(L+M)
SL_I = mb026(5,:)./LpM;   % I/(L+M)

%% daylight locus (CIE daylight phases 4000-13000 K)
cct = [4000, 5000, 5500, 6000, 6500, 7000, 7500, 8000, 9000, 10000, 11000, 12000, 13000];
mb026_5nm = mb026(:,1:5:end);   % 5 nm grid to match the daylight SPDs
mb026_5nm(isnan(mb026_5nm)) = 0;
DLmb = zeros(3, numel(cct));    % row 1 = S/(L+M), 2 = L/(L+M), 3 = I/(L+M)
load('B_cieday.mat');
for i = 1:numel(cct)
    DL = GenerateCIEDay(cct(i), B_cieday);
    normDL = DL./trapz(380:5:780, DL);
    c = mb026_5nm*normDL(3:end);                 % [S M L Rod I]'
    DLmb(1,i) = c(1)./(c(2)+c(3));               % S/(L+M)
    DLmb(2,i) = c(3)./(c(2)+c(3));               % L/(L+M)
    DLmb(3,i) = c(5)./(c(2)+c(3));               % I/(L+M)
end

% colours
map  = colorcet('rainbow');   % spectral locus crosses, by wavelength
map2 = flipud(colorcet('bjy'));  % daylight locus dots, by CCT (warm 4000K -> cool 13000K)
close all;

scMarks = round(linspace(11,361,15));   % 25 nm steps (400:25:750 nm) along the locus

% --- shared axis styling helper (applied inline per panel) ---------------
% Panels 2a/2b/2c are each one third of the two-column width so the three
% tile side-by-side; formatting matches plot_figure3.m (centimetres, figp).

%% plot Fig2a - S/(L+M) vs L/(L+M)  (full range)
fig = figure;hold on;ax = gca;
plot(SL_L, SL_S, 'Color','k','LineWidth',1.5);
for i = scMarks
    plot(SL_L(i), SL_S(i), 'x','Color',map(round(256*i/391),:),'MarkerSize',7,'LineWidth',1.5);
end
plot(DLmb(2,:), DLmb(1,:), 'Color',[0,0,0.8],'LineWidth',1.5);
for i = 1:2:13
    plot(DLmb(2,i), DLmb(1,i), '.','Color',map2(round(256*i/13),:),'MarkerSize',14);
end
xlabel('L/(L+M)');ylabel('S/(L+M)');
xlim([0.48,1]);ylim([0,1]);
xticks(0.5:0.1:1);yticks(0:0.2:1);
xtickformat('%.1f');ytickformat('%.1f');
ax.FontName='Arial';ax.Units='centimeters';ax.XColor='k';ax.YColor='k';
ax.FontSize=figp.fontsize;ax.LineWidth=0.5;ax.Position=[1.0 0.8 4.2 4.2*vscale];
grid on;box on;
fig.Units='centimeters';fig.Color='w';fig.InvertHardcopy='off';
fig.PaperPosition=[0,10,8.45,8.45];
fig.Position=[10,10,figp.twocolumn/3*0.95,figp.twocolumn/3*0.95*vscale];
drawnow;
exportgraphics(fig, fullfile(figsDir,'fig2a.pdf'),'ContentType','vector');

%% plot Fig2a inset - daylight locus zoom (drop into fig2a)
fig = figure;hold on;ax = gca;
plot(DLmb(2,:), DLmb(1,:), 'Color',[0,0,0.8],'LineWidth',1.5);
for i = 1:2:13
    plot(DLmb(2,i), DLmb(1,i), '.','Color',map2(round(256*i/13),:),'MarkerSize',14);
end
xlim([0.65,0.72]);ylim([0.015,0.045]);
xticks([0.66,0.69,0.72]);yticks([0.02,0.03,0.04]);
ax.FontName='Arial';ax.Units='centimeters';ax.XColor='k';ax.YColor='k';
ax.FontSize=figp.fontsize;ax.LineWidth=0.5;ax.Position=[0.7 0.8 2.3 2.3*vscale];
grid on;box on;
fig.Units='centimeters';fig.Color='w';fig.InvertHardcopy='off';
fig.PaperPosition=[0,10,8.45,8.45];
fig.Position=[10,10,figp.twocolumn/5*0.95,figp.twocolumn/5*0.95*vscale];
drawnow;
exportgraphics(fig, fullfile(figsDir,'fig2a_insert.pdf'),'ContentType','vector');

%% plot Fig2b - I/(L+M) vs L/(L+M)  (full range)
fig = figure;hold on;ax = gca;
plot(SL_L, SL_I, 'Color','k','LineWidth',1.5);
for i = scMarks
    plot(SL_L(i), SL_I(i), 'x','Color',map(round(256*i/391),:),'MarkerSize',7,'LineWidth',1.5);
end
plot(DLmb(2,:), DLmb(3,:), 'Color',[0,0,0.8],'LineWidth',1.5);
for i = 1:2:13
    plot(DLmb(2,i), DLmb(3,i), '.','Color',map2(round(256*i/13),:),'MarkerSize',14);
end
xlabel('L/(L+M)');ylabel('I/(L+M)');
xlim([0.48,1]);ylim([0,1]);
xticks(0.5:0.1:1);yticks(0:0.2:1);
xtickformat('%.1f');ytickformat('%.1f');
ax.FontName='Arial';ax.Units='centimeters';ax.XColor='k';ax.YColor='k';
ax.FontSize=figp.fontsize;ax.LineWidth=0.5;ax.Position=[1.0 0.8 4.2 4.2*vscale];
grid on;box on;
fig.Units='centimeters';fig.Color='w';fig.InvertHardcopy='off';
fig.PaperPosition=[0,10,8.45,8.45];
fig.Position=[10,10,figp.twocolumn/3*0.95,figp.twocolumn/3*0.95*vscale];
drawnow;
exportgraphics(fig, fullfile(figsDir,'fig2b.pdf'),'ContentType','vector');

%% plot Fig2b inset - daylight locus zoom (drop into fig2b)
fig = figure;hold on;ax = gca;
plot(DLmb(2,:), DLmb(3,:), 'Color',[0,0,0.8],'LineWidth',1.5);
for i = 1:2:13
    plot(DLmb(2,i), DLmb(3,i), '.','Color',map2(round(256*i/13),:),'MarkerSize',14);
end
xlim([0.65,0.72]);ylim([0.07,0.14]);
xticks([0.66,0.69,0.72]);yticks([0.08,0.11,0.14]);
ax.FontName='Arial';ax.Units='centimeters';ax.XColor='k';ax.YColor='k';
ax.FontSize=figp.fontsize;ax.LineWidth=0.5;ax.Position=[0.7 0.8 2.3 2.3*vscale];
grid on;box on;
fig.Units='centimeters';fig.Color='w';fig.InvertHardcopy='off';
fig.PaperPosition=[0,10,8.45,8.45];
fig.Position=[10,10,figp.twocolumn/5*0.95,figp.twocolumn/5*0.95*vscale];
drawnow;
exportgraphics(fig, fullfile(figsDir,'fig2b_insert.pdf'),'ContentType','vector');

%% plot Fig2c - S/(L+M) vs I/(L+M)  (full range)
fig = figure;hold on;ax = gca;
plot(SL_I, SL_S, 'Color','k','LineWidth',1.5);
for i = scMarks
    plot(SL_I(i), SL_S(i), 'x','Color',map(round(256*i/391),:),'MarkerSize',7,'LineWidth',1.5);
end
plot(DLmb(3,:), DLmb(1,:), 'Color',[0,0,0.8],'LineWidth',1.5);
for i = 1:2:13
    plot(DLmb(3,i), DLmb(1,i), '.','Color',map2(round(256*i/13),:),'MarkerSize',14);
end
xlabel('I/(L+M)');ylabel('S/(L+M)');
xlim([-0.03,1]);ylim([0,1]);
xticks(0:0.2:1);yticks(0:0.2:1);
xtickformat('%.1f');ytickformat('%.1f');
ax.FontName='Arial';ax.Units='centimeters';ax.XColor='k';ax.YColor='k';
ax.FontSize=figp.fontsize;ax.LineWidth=0.5;ax.Position=[1.0 0.8 4.2 4.2*vscale];
grid on;box on;
fig.Units='centimeters';fig.Color='w';fig.InvertHardcopy='off';
fig.PaperPosition=[0,10,8.45,8.45];
fig.Position=[10,10,figp.twocolumn/3*0.95,figp.twocolumn/3*0.95*vscale];
drawnow;
exportgraphics(fig, fullfile(figsDir,'fig2c.pdf'),'ContentType','vector');

%% plot Fig2c inset - daylight locus zoom (drop into fig2c)
fig = figure;hold on;ax = gca;
plot(DLmb(3,:), DLmb(1,:), 'Color',[0,0,0.8],'LineWidth',1.5);
for i = 1:2:13
    plot(DLmb(3,i), DLmb(1,i), '.','Color',map2(round(256*i/13),:),'MarkerSize',14);
end
xlim([0.07,0.14]);ylim([0.015,0.045]);
xticks([0.08,0.11,0.14]);yticks([0.02,0.03,0.04]);
ax.FontName='Arial';ax.Units='centimeters';ax.XColor='k';ax.YColor='k';
ax.FontSize=figp.fontsize;ax.LineWidth=0.5;ax.Position=[0.7 0.8 2.3 2.3*vscale];
grid on;box on;
fig.Units='centimeters';fig.Color='w';fig.InvertHardcopy='off';
fig.PaperPosition=[0,10,8.45,8.45];
fig.Position=[10,10,figp.twocolumn/5*0.95,figp.twocolumn/5*0.95*vscale];
drawnow;
exportgraphics(fig, fullfile(figsDir,'fig2c_insert.pdf'),'ContentType','vector');
