% First developed by ACS, modified by TM.
function D = load_tm30_data(~)
% load_tm30_data  Load and cache the static reference data for TM-30-18.
%   D = load_tm30_data() returns a struct with fields:
%     wl       81x1  wavelengths 380:5:780 (nm)
%     tcs      81x99 CIE 2017 / TM-30 test colour sample reflectances
%     cmf2     81x4  [wl xbar ybar zbar] CIE 1931 2-deg observer (CCT step)
%     cmf10    81x4  [wl xbar ybar zbar] CIE 1964 10-deg observer (everything else)
%     dayBasis 81x4  [wl S0 S1 S2] CIE daylight component functions
%
%   The underlying arrays are stored in the consolidated data/data.mat
%   (data.tm30_tcs, data.tm30_cmf_2deg, data.tm30_cmf_10deg,
%   data.cie_daylight_basis). The result is cached across calls. The optional
%   argument is accepted for backwards compatibility and ignored.

    persistent CACHE
    if ~isempty(CACHE), D = CACHE; return; end

    data = load_data();
    tcs = data.tm30_tcs;                    % 81 x (1+99)
    D.wl  = tcs(:,1);
    D.tcs = tcs(:,2:end);
    D.cmf2  = data.tm30_cmf_2deg;
    D.cmf10 = data.tm30_cmf_10deg;
    D.dayBasis = data.cie_daylight_basis;

    assert(numel(D.wl)==81 && abs(D.wl(1)-380)<1e-9 && abs(D.wl(end)-780)<1e-9, ...
        'TM-30 data must be on the 380:5:780 grid.');
    CACHE = D;
end
