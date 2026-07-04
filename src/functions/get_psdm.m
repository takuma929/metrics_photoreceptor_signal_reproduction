% function to calculate the photoreceptor distortion metric
% First developed by ACS, modified by TM.

function [display] = get_psdm(display,Sim)

% inputs:
% 1) structure of display
% 2) structure of simulated real world spectra

% outputs:
% display structure containing fields for distorted photoreceptor signal
% metric

% calculate distortion for all photoreceptors if reproducible (i.e.
% primaries non-zero and non-negative)
refSignals = Sim.ss;
diffSignals = display.alphaReproduced - refSignals;
zeroRef = refSignals == 0;
distortionMetric = nan(size(diffSignals));
nonzeroRef = ~zeroRef;
distortionMetric(nonzeroRef) = 100 .* (diffSignals(nonzeroRef) ./ refSignals(nonzeroRef));
% For zero reference signals, count exact reproduction as zero distortion
% and otherwise express the absolute error on the display's normalized signal scale.
distortionMetric(zeroRef & display.alphaReproduced == 0) = 0;
distortionMetric(zeroRef & display.alphaReproduced ~= 0) = 100 .* abs(display.alphaReproduced(zeroRef & display.alphaReproduced ~= 0));

display.distortionMetric = distortionMetric;
% calculate mean of absolute value of distortion for each photoreceptor
% ignoring undefined values when reference signals are zero
display.meanAbsDistortion = mean(abs(display.distortionMetric),2,'omitnan');
% calculate mean distortion
display.meanDistortion = mean((display.distortionMetric),2,'omitnan');
% calculate standard deviation of distortions
display.stdDistortion = std((display.distortionMetric),[],2,'omitnan');

% calculate overall psdm of display - mean of mean of absolute value of distortions
% for each photoreceptor
display.psdm = mean(display.meanAbsDistortion,'omitnan');

% Print exact computed PSDM values so the user can inspect whether
% values are truly zero or just very small.
if isfield(display, 'quantizedBitDepth') && isfinite(display.quantizedBitDepth)
    bitLabel = sprintf('%dbit', display.quantizedBitDepth);
else
    bitLabel = 'continuous';
end
fprintf('get_psdm: PSDM = %.8f, meanAbsDistortion = [%s], meanDistortion = [%s], stdDistortion = [%s], zeroRefPairs = %d\n', ...
    display.psdm, ...
    num2str(display.meanAbsDistortion','%.8f '), ...
    num2str(display.meanDistortion','%.8f '), ...
    num2str(display.stdDistortion','%.8f '), ...
    sum(isnan(display.distortionMetric(:))));

end