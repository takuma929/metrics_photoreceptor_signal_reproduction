% function to find the photoreceptor correlation distortions
% First developed by ACS, modified by TM.
      
function [display] = get_colour_gamut(display,Sim);

% inputs:
% 1) structure of display
% 2) structure of simulated real world spectra

% outputs:
% display structure containing field for chromaticity reproduction metric

totalSpec = length(Sim.ss);
[in, on] = inpolygon(Sim.xyY(1,:),Sim.xyY(2,:),display.xyYMax(1,display.idx),display.xyYMax(2,display.idx));
display.chromaticityReproductionMetric=100.*(sum(in)./totalSpec);

end