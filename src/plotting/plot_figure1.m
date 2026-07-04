% plot Figure 1 of paper
% plots spectral sensitivities, example real-world specturm, example
% display primaries, example real-world signals, and example reproduced
% signals, with example introduced contrast
% First developed by ACS, modified by TM.

% --- project paths (location-independent) ---
projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(fullfile(projectRoot, 'data'));
dataDir = fullfile(projectRoot, 'data');
resDir  = fullfile(projectRoot, 'results');
figsDir = fullfile(projectRoot, 'figs');
if ~exist(figsDir, 'dir'); mkdir(figsDir); end

%% load data
figp = load_data().fig_parameters;
ss = get_cies026;
wlsCIES026 = (390:1:780)';
T_cies026 = ss(:,11:end);
T_cies026(isnan(T_cies026)) = 0;

%% set-up colors for l-cone, m-cone, s-cone, rod, ipRGC
lmsriCol = [0 0 .5;0 0.5 0;.5 0 0;0 0.5 0.5;0.5 0 .5];

vscale = 0.9;
lwidth = 0.5;
%% plot Fig1(a) - spectral sensitivities of S,M,L,R,I
fig = figure;hold on;ax = gca;

x = 390:780;
for ii = 1:5
    y = T_cies026(ii,:);
    % fill area under the curve
    fill([x fliplr(x)], [y zeros(size(y))], lmsriCol(ii,:), ...
        'FaceAlpha', 0.03, 'EdgeColor', 'none');
    % plot the line on top
    h(ii) = plot(x, y, 'Color', lmsriCol(ii,:), 'LineWidth', lwidth);
end

ax.XLim = [390,780];ax.YLim = [0,1.05];
xticks([400 500 600 700 780]);yticks([0 0.5 1])
ax.XTickLabel = {'400','500','600','700','780'};ax.YTickLabel = {};
xlabel('Wavelength [nm]');ylabel('Spectral sensitivity');

ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
ax.FontSize = figp.fontsize;
ax.LineWidth = 0.5;
ax.Position = [0.7 0.8 4.6 4.6*vscale];

fig.Units = 'centimeters';fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/3*0.95,figp.twocolumn/3*0.95*vscale];

grid on;box off;
%axis square
    drawnow;
    exportgraphics(fig, fullfile(figsDir,'fig1a.pdf'),'ContentType','vector');

%%  plot Fig1b - example real-world spectrum
fig = figure;hold on;ax = gca;

% generate daylight spectrum
simRad = get_simulated_spectra;
worldSpd = simRad(:,39230); % pick a random spectrum as an example from the simulated spectra
worldSpd = SplineSpd([390,5,79], worldSpd, [390,1,391]);
h(1)=plot(390:780,worldSpd/max(worldSpd(:)),'k','LineWidth',lwidth);
fill(390:780,worldSpd/max(worldSpd(:)),[.7 .7 .7],'FaceAlpha', 0.2, 'EdgeColor', 'none');

ax.XLim = [390,780];ax.YLim = [0,1.05];
xticks([400 500 600 700 780]);yticks([0 0.5 1])
ax.XTickLabel = {'400','500','600','700','780'};ax.YTickLabel = {};
xlabel('Wavelength [nm]');ylabel('Relative Power');

ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
ax.FontSize = figp.fontsize;
ax.LineWidth = 0.5;
ax.Position = [0.7 0.8 4.6 4.6*vscale];

fig.Units = 'centimeters';fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/3*0.95,figp.twocolumn/3*0.95*vscale];

grid on;box off;
%axis square

    drawnow;
    exportgraphics(fig, fullfile(figsDir,'fig1b.pdf'),'ContentType','vector');

%%  plot Fig1c - example three primary display primaries
fig = figure;hold on;ax = gca;

% generate daylight spectrum
bbR = normpdf(390:780,450,(40./2.355));
bbG = normpdf(390:780,560,(40./2.355));
bbB = normpdf(390:780,630,(40./2.355));
wlsbb = 390:780;
spd = [bbR',bbG',bbB'];

% noramlise so area under primaries is 1
for i=1:size(spd,2)
    % calculate integral of illuminant spectra
    A(i) = trapz(wlsbb, spd(:,i));
    spd(:,i) = spd(:,i)./A(i);
end

hold on;
x = (390:780)';y = spd(:,3);
h(1)=plot(x,y,'Color',lmsriCol(3,:),'LineWidth',lwidth);
fill([x fliplr(x)], [y zeros(size(y))], lmsriCol(3,:), ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');

y = spd(:,2);
h(2)=plot(x,y,'Color',lmsriCol(2,:),'LineWidth',lwidth);
fill([x fliplr(x)], [y zeros(size(y))], lmsriCol(2,:), ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');

y = spd(:,1);
h(3)=plot(x,y,'Color',lmsriCol(1,:),'LineWidth',lwidth);
fill([x fliplr(x)], [y zeros(size(y))], lmsriCol(1,:), ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');

ax.XLim = [390,780];ax.YLim = [0,0.0245];
xticks([400 500 600 700 780]);yticks([])
ax.XTickLabel = {'400','500','600','700','780'};ax.YTickLabel = {};
xlabel('Wavelength [nm]');ylabel('Relative Power');

ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
ax.FontSize = figp.fontsize;
ax.LineWidth = 0.5;
ax.Position = [0.7 0.8 4.6 4.6*vscale];

fig.Units = 'centimeters';fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/3*0.95,figp.twocolumn/3*0.95*vscale];

grid on;box off;
%axis square

    drawnow;
    exportgraphics(fig, fullfile(figsDir,'fig1c.pdf'),'ContentType','vector');

%% calculate cone, rod, and melanopsin responses to worldSpd and display
lmsworldSpd = T_cies026(1:3,:)*worldSpd; % lms from worldSpd
LMS2RGB = T_cies026(1:3,:)*spd; % get RGB->LMS conversion for display
rgb = inv(LMS2RGB) * lmsworldSpd; % calculate RGB needed to match LMS to worldSpd
dispspd = rgb(1).*spd(:,1)+rgb(2).*spd(:,2)+rgb(3).*spd(:,3); % calculate output spectrum of display
lmsri3PDisp = T_cies026*dispspd;
lmsriworldSpd = T_cies026*worldSpd;

%%  plot Fig1d - spectral output from display
fig = figure;hold on;ax = gca;

x = (390:780)';
y = dispspd;

h(1)=plot(x,y,'Color','k','LineWidth',lwidth);
fill([x fliplr(x)], [y zeros(size(y))], [.7 .7 .7], ...
    'FaceAlpha', 0.2, 'EdgeColor', 'none');

ax.XLim = [390,780];ax.YLim = [0,0.0021];
xticks([400 500 600 700 780]);yticks([])
ax.XTickLabel = {'400','500','600','700','780'};ax.YTickLabel = {};
xlabel('Wavelength [nm]');ylabel('Relative Power');

ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
ax.FontSize = figp.fontsize;
ax.LineWidth = 0.5;
ax.Position = [0.7 0.8 4.6 4.6*vscale];

fig.Units = 'centimeters';fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/3*0.95,figp.twocolumn/3*0.95*vscale];

grid on;box off;
%axis square

    drawnow;
    exportgraphics(fig, fullfile(figsDir,'fig1d.pdf'),'ContentType','vector');

%% Fig 1e - cone, rod, and melanopsin responses to real-world spectrum and display spectrum
fig = figure;hold on;ax = gca;
b = bar([lmsriworldSpd'; lmsri3PDisp']','EdgeColor','none','BarWidth',0.9);
b(1,1).FaceColor = 'flat';
b(1,1).CData(3,:) = [.5 0 0];
b(1,1).CData(2,:) = [0 .5 0];
b(1,1).CData(1,:) = [0 0 .5];
b(1,1).CData(4,:) = lmsriCol(4,:);
b(1,1).CData(5,:) = lmsriCol(5,:);
b(1,2).FaceColor = 'flat';
b(1,2).CData(3,:) = 1.75*[.5 0 0];
b(1,2).CData(2,:) = 1.75*[0 .5 0];
b(1,2).CData(1,:) = 1.75*[0 0 .5];
b(1,2).CData(4,:) = 1.75*lmsriCol(4,:);
b(1,2).CData(5,:) = 1.75*lmsriCol(5,:);

ax.XLim = [0.5 5.5];ax.YLim = [0,0.09];
xticks([1 2 3 4 5]);yticks([])
ax.XTickLabel = {'S','M','L','R','I'};ax.YTickLabel = {};
xlabel('Photoreceptor class');ylabel('Response');

ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
ax.FontSize = figp.fontsize;
ax.LineWidth = 0.5;
ax.Position = [0.7 0.8 4.6 4.6*vscale];

fig.Units = 'centimeters';fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/3*0.95,figp.twocolumn/3*0.95*vscale];

grid off;box off;
%axis square

    drawnow;
    exportgraphics(fig, fullfile(figsDir,'fig1e.pdf'),'ContentType','vector');

%%  plot Fig1f - example five primary display primaries
fig = figure;hold on;ax = gca;
% generate daylight spectrum
bbR = normpdf(390:780,460,(40./2.355));
bbG = normpdf(390:780,530,(40./2.355));
bbB = normpdf(390:780,580,(40./2.355));
bbC = normpdf(390:780,610,(40./2.355));
bbM = normpdf(390:780,650,(40./2.355));
wlsbb = 390:780;
spd5 = [bbR',bbG',bbB',bbC',bbM'];

% noramlise so area under primaries is 1
for i=1:size(spd5,2)
    % calculate integral of illuminant spectra
    A(i) = trapz(wlsbb, spd5(:,i));
    spd5(:,i) = spd5(:,i)./A(i);
end
hold on;
x = (390:780)';y = spd5(:,1);
h(1)=plot(x,y,'Color',lmsriCol(1,:),'LineWidth',lwidth);
fill([x fliplr(x)], [y zeros(size(y))], lmsriCol(1,:), ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');

y = spd5(:,2);
h(2)=plot(x,y,'Color',lmsriCol(2,:),'LineWidth',lwidth);
fill([x fliplr(x)], [y zeros(size(y))], lmsriCol(2,:), ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');

y = spd5(:,5);
h(3)=plot(x,y,'Color',lmsriCol(3,:),'LineWidth',lwidth);
fill([x fliplr(x)], [y zeros(size(y))], lmsriCol(3,:), ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');

y = spd5(:,4);
h(3)=plot(x,y,'Color',[0.4940,0.1840,0.5560],'LineWidth',lwidth);
fill([x fliplr(x)], [y zeros(size(y))], [0.4940,0.1840,0.5560], ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');

y = spd5(:,3);
h(3)=plot(x,y,'Color',[0.9290,0.6940,0.1250],'LineWidth',lwidth);
fill([x fliplr(x)], [y zeros(size(y))], [0.9290,0.6940,0.1250], ...
    'FaceAlpha', 0.03, 'EdgeColor', 'none');

ax.XLim = [390,780];ax.YLim = [0,0.0245];
xticks([400 500 600 700 780]);yticks([])
ax.XTickLabel = {'400','500','600','700','780'};ax.YTickLabel = {};
xlabel('Wavelength [nm]');ylabel('Relative Power');

ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
ax.FontSize = figp.fontsize;
ax.LineWidth = 0.5;
ax.Position = [0.7 0.8 4.6 4.6*vscale];

fig.Units = 'centimeters';fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/3*0.95,figp.twocolumn/3*0.95*vscale];

grid on;box off;
%axis square

    drawnow;
    exportgraphics(fig, fullfile(figsDir,'fig1f.pdf'),'ContentType','vector');

%% calculate cone, rod, and melanopsin responses to five primary display display
lmsriworldSpd = T_cies026*worldSpd; % lms from worldSpd
LMSRI2RGBCM = T_cies026*spd5; % get RGB->LMS conversion for display
rgbcm = inv(LMSRI2RGBCM) * lmsriworldSpd; % calculate RGB needed to match LMS to worldSpd
dispspd5 = rgbcm(1).*spd5(:,1)+rgbcm(2).*spd5(:,2)+rgbcm(3).*spd5(:,3)+rgbcm(4).*spd5(:,4)+rgbcm(5).*spd5(:,5); % calculate output spectrum of display
lmsri5PDisp = T_cies026*dispspd5; % lmsri from display output

%% plot Fig 1g - spectral output of 5P display
fig = figure;hold on;ax = gca;

x = (390:780)';y = dispspd5;
h(1)=plot(x,y,'Color',[0.25,0.25,0.25],'LineWidth',lwidth);
fill([x fliplr(x)], [y zeros(size(y))], [.7 .7 .7], ...
    'FaceAlpha', 0.2, 'EdgeColor', 'none');

ax.XLim = [390,780];ax.YLim = [0,0.0021];
xticks([400 500 600 700 780]);yticks([])
ax.XTickLabel = {'400','500','600','700','780'};ax.YTickLabel = {};
xlabel('Wavelength [nm]');ylabel('Relative Power');

ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
ax.FontSize = figp.fontsize;
ax.LineWidth = 0.5;
ax.Position = [0.7 0.8 4.6 4.6*vscale];

fig.Units = 'centimeters';fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/3*0.95,figp.twocolumn/3*0.95*vscale];

grid on;box off;
%axis square

    drawnow;
    exportgraphics(fig, fullfile(figsDir,'fig1g.pdf'),'ContentType','vector');

%% plot Fig 1h - cone, rod and mel responses to real-world spectrum and display spectrum
fig = figure;hold on;ax = gca;
b = bar([lmsriworldSpd'; lmsri5PDisp']','EdgeColor','none','BarWidth',0.9);
b(1,1).FaceColor = 'flat';
b(1,1).CData(3,:) = [.5 0 0];
b(1,1).CData(2,:) = [0 .5 0];
b(1,1).CData(1,:) = [0 0 .5];
b(1,1).CData(4,:) = lmsriCol(4,:);
b(1,1).CData(5,:) = lmsriCol(5,:);
b(1,2).FaceColor = 'flat';
b(1,2).CData(3,:) = 1.75*[.5 0 0];
b(1,2).CData(2,:) = 1.75*[0 .5 0];
b(1,2).CData(1,:) = 1.75*[0 0 .5];
b(1,2).CData(4,:) = 1.75*lmsriCol(4,:);
b(1,2).CData(5,:) = 1.75*lmsriCol(5,:);

ax.XLim = [0.5 5.5];ax.YLim = [0,0.09];
xticks([1 2 3 4 5]);yticks([])
ax.XTickLabel = {'S','M','L','R','I'};ax.YTickLabel = {};
xlabel('Photoreceptor class');ylabel('Response');

ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
ax.FontSize = figp.fontsize;
ax.LineWidth = 0.5;
ax.Position = [0.7 0.8 4.6 4.6*vscale];

fig.Units = 'centimeters';fig.Color = 'w';
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/3*0.95,figp.twocolumn/3*0.95*vscale];

grid off;box off;
%axis square

    drawnow;
    exportgraphics(fig, fullfile(figsDir,'fig1h.pdf'),'ContentType','vector');

%% plot Fig 1e2 - contrasts
fig = figure;hold on;ax = gca;
contrasts = 100*[abs(lmsri3PDisp(4:5)'-lmsriworldSpd(4:5)')./lmsriworldSpd(4:5)']';
b = bar(contrasts,'EdgeColor','none','BarWidth',0.5);
b(1,1).FaceColor = 'flat';
b(1,1).FaceColor = 'flat';
b(1,1).CData(1,:) = lmsriCol(4,:);
b(1,1).CData(2,:) = lmsriCol(5,:);

ax.XLim = [0.5 2.5];ax.YLim = [0,22];
xticks([1 2 3 4 5]);yticks([0 10 20])
ax.XTickLabel = {'R','I'};ax.YTickLabel = {'0','10','20'};
xlabel('');ylabel('Contrast [%]');

ax.FontName = 'Arial';
ax.Units = 'centimeters';
ax.Color = [.97 .97 .97];
ax.XColor = 'k';ax.YColor = 'k';
ax.FontSize = figp.fontsize-2;
ax.LineWidth = 0.5;
ax.Position = [0.8 0.6 1.2 1.2];

fig.Units = 'centimeters';fig.Color = [.97 .97 .97];
fig.InvertHardcopy = 'off';
fig.PaperPosition   = [0,10,8.45,8.45];
fig.Position = [10,10,figp.twocolumn/8,figp.twocolumn/8*0.95];

grid off;box off;axis square

    drawnow;
    exportgraphics(fig, fullfile(figsDir,'fig1e_inserted.pdf'),'ContentType','vector','BackgroundColor','none');

%%
close all

