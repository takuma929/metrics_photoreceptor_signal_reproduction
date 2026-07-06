% ─────────────────────────────────────────────────────────────────────────────
%  Vendored from Psychtoolbox-3, version 3.0.18 (PsychColorimetric).
%  Original file: PsychColorimetric/MakeItS.m
%  Source:    https://github.com/Psychtoolbox-3/Psychtoolbox-3
%  Copyright: (c) 1996-2018 David Brainard and the Psychtoolbox core developers.
%  License:   MIT (Psychtoolbox-3 default license). See psychtoolbox/NOTICE.md.
%
%  Included verbatim so that this toolbox runs without a Psychtoolbox install.
%  The code below is unmodified from the original; only this header was added.
% ─────────────────────────────────────────────────────────────────────────────

function S = MakeItS(wls)
% S = MakeItS(wls)
%
% If argument is a [start delta n] description, it is
% left alone.
%
% If passed length is not a [start delta n] description,
% convert it to one.  Formats handled are a list of evenly
% spaced wavelengths or a struct with fields start, step, numberSamples.
%
% Format error checking could be more agressive.
%
% 7/26/02  dhb  Allow struct format too.

% Force passed description to S format.
[m,n] = size(wls);
if (isstruct(wls))
	S = [wls.start wls.step wls.numberSamples];
elseif (m == 1 && n == 3)
  if (wls(1) >= 0 && wls(3) > 0)
    S = wls;
  else
    error('Passed wls is not interpretable');
  end
else
  S = WlsToS(wls);
end


