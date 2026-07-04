% function to find the distorted reproduction metric
% First developed by ACS, modified by TM.
      
function [display] = get_psrm(display,Sim,epsilon)

% inputs:
% 1) structure of display
% 2) structure of simulated real world spectra
% 3) tolerance value (e.g. 0.01)

% outputs:
% display structure containing fields for Photoreceptor Signal Reproduction
% Metric (PSRM)

% This section of the code was written in response to an anonymous reviewer’s comment — thank you.
error = abs(display.alphaReproduced - Sim.ss)./Sim.ss;
psrm = sum(sum(error > epsilon, 1) == 0)./length(error);
display.realworldReproductionMetric = 100*psrm;

end
