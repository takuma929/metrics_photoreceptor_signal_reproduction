% function to find the photoreceptor correlation distortions
% First developed by ACS, modified by TM.
      
function [display] = get_pcdm(display,Sim);

% inputs:
% 1) structure of display
% 2) structure of simulated real world spectra

% outputs:
% display structure containing fields for distorted photoreceptor
% correlations

% pairings for correlations
pairs = [1,2;1,3;1,4;1,5;,2,3;2,4;2,5;3,4;3,5;4,5];
pairNames = ['S','M';'S','L';'S','R';'S','I';'M','L';'M','R';'M','I';'L','R';'L','I';'R','I'];

for ii=1:length(pairs)
    [rho{ii}, pval{ii}] = corrcoef(display.ssDistorted(pairs(ii,1),display.ssReproducible),display.ssDistorted(pairs(ii,2),display.ssReproducible));
   	display.photoreceptorCorrelations(ii) = rho{ii}(1,2);
    [rhoSimReproducible{ii}, pval{ii}] = corrcoef(Sim.ss(pairs(ii,1),display.ssReproducible),Sim.ss(pairs(ii,2),display.ssReproducible)); %only compare against correlation in real-world of spectra that can be reproduced on the display
    %display.photoreceptorCorrelationsDistortion(ii) = round(100*((display.photoreceptorCorrelations(ii)-rhoSimReproducible{ii}(1,2))./rhoSimReproducible{ii}(1,2)),1);
    display.photoreceptorCorrelationsDistortion(ii) = round(display.photoreceptorCorrelations(ii)-rhoSimReproducible{ii}(1,2),2); % try out raw correlation distortion here as opposed to % change
end

display.correlationLabels = pairNames;

end