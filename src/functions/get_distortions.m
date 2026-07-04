% function to find the photoreceptor signal distortions introduced when
% trying to reproduce the real-world spectra on a display
% First developed by ACS, modified by TM.

function [display] = get_distortions(matchedSignals,Sim,display,displayPrimaries,T_cies026,mb026,smallestBit,nPrimaries,epsilon,bits)

% inputs:
% 1) which photoreceotpr signals to match, vector including elements from 1-5 where 1=S;2=M;3=L;4=R;5=I
% 2) structure of simulated real world spectra
% 3) structure of display
% 4) primaries of the display
% 5) photoreceptor spectral sensitivities
% 6) MacLeod-Boynton chromaticity coordinates to produce extended
%    MacLeod-Boynton diagram
% 7) smallest bit that display can achieve, for example, for an 8-bit display this would be 1./255
% 8) number of primaries in display
% 9) tolerance value for reproduction error
% 10) bits: optional quantization bit depth for display channel weights

% outputs:
% display structure containing fields for distorted photoreceptor signals
% and which of those distorted signals can be reproduced on the display

if nargin < 10 || isempty(bits) || ~isfinite(bits)
    quantizeBits = false;
else
    quantizeBits = true;
    bitLevels = 2^bits - 1;
end

% This section of the code was written in response to an anonymous reviewer’s comment — thank you.

lScale = 0.69283932;
mScale = 0.34967567;
sScale = 0.05547858;
iScale = 0.1317;

lmsri = T_cies026 * displayPrimaries;
p = zeros(size(lmsri, 2), size(Sim.ss, 2)); % Preallocate weight p
A = lmsri(matchedSignals,:);

for ii = 1:size(Sim.ss,2)
    b = Sim.ss(matchedSignals, ii);
    weights = lsqnonneg(A, b);
    weights = max(weights, 0);
    if quantizeBits
        % Fixed-intensity model: the display reproduces the real-world spectrum
        % at its given absolute level and CANNOT rescale the overall intensity to
        % use more of the bit range. Drive weights are clamped to the realizable
        % [0,1] range (weights > 1 are beyond full drive, i.e. not reproducible)
        % and quantized at the display's fixed full-scale resolution.
        weights = min(weights, 1);
        weights = round(weights * bitLevels) / bitLevels;
    end
    p(:, ii) = weights;
end

alphaReproduced = lmsri * p;
error = abs(alphaReproduced - Sim.ss);
nonzeroRef = Sim.ss ~= 0;
error(nonzeroRef) = error(nonzeroRef) ./ abs(Sim.ss(nonzeroRef));
zeroRef = Sim.ss == 0;
error(zeroRef) = abs(alphaReproduced(zeroRef));
psrm = sum(sum(error > epsilon, 1) == 0) ./ size(error, 2);

display.alphaReproduced = alphaReproduced;
if quantizeBits
    display.quantizedBitDepth = bits;
    display.alphaReproducedQuantized = alphaReproduced;
else
    display.quantizedBitDepth = Inf;
end

l_distorted = alphaReproduced(3,:) * lScale;
m_distorted = alphaReproduced(2,:) * mScale;
s_distorted = alphaReproduced(1,:) * sScale;
i_distorted = alphaReproduced(5,:) * iScale;

display.mbDistorted(1,:) = l_distorted ./ (l_distorted + m_distorted);
display.mbDistorted(2,:) = s_distorted ./ (l_distorted + m_distorted);
display.mbDistorted(3,:) = i_distorted ./ (l_distorted + m_distorted);
end
