% First developed by ACS, modified by TM.
% script to get the spectral locus spectra over the specified wavelength
% range

function slSPD = get_spectral_locus_spectra(wls)

% simulate spectral locus with delta functions
slSPD = zeros(size(wls,2),size(wls,2));
for ii=1:size(wls,2)
    slSPD(ii,ii) = 1;
end

end

