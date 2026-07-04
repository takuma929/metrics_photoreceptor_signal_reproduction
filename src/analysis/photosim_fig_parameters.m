% First developed by ACS, modified by TM.
clearvars;clc;close all

% --- project paths (location-independent) ---
projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(genpath(fullfile(projectRoot, 'src')));
addpath(fullfile(projectRoot, 'data'));
addpath(fullfile(projectRoot, 'results'));
dataDir = fullfile(projectRoot, 'data');
resDir  = fullfile(projectRoot, 'results');
figsDir = fullfile(projectRoot, 'figs');
if ~exist(figsDir, 'dir'); mkdir(figsDir); end

% script to save parameters for figure generation
figp.twocolumn = 17.9; % size for for two-column figure (Color Research and Application)
figp.onecolumn = figp.twocolumn/2; % size for for one-column figure (Color Research and Application)

figp.fontsize = 8; % fontsize for general use
figp.fontsize_axis = 9; % fontsize for axis label
figp.fontname = 'Helvetica'; % Use Arial for font

% save figure parameter
save(fullfile(dataDir,'photoSim_FigParameters'),'figp')