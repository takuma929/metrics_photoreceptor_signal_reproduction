% ─────────────────────────────────────────────────────────────────────────────
%  Vendored from Psychtoolbox-3, version 3.0.18 (PsychColorimetric).
%  Original file: PsychColorimetric/MakeItWls.m
%  Source:    https://github.com/Psychtoolbox-3/Psychtoolbox-3
%  Copyright: (c) 1996-2018 David Brainard and the Psychtoolbox core developers.
%  License:   MIT (Psychtoolbox-3 default license). See psychtoolbox/NOTICE.md.
%
%  Included verbatim so that this toolbox runs without a Psychtoolbox install.
%  The code below is unmodified from the original; only this header was added.
% ─────────────────────────────────────────────────────────────────────────────

function wls = MakeItWls(S)
% wls = MakeItWls(S)
%
% If argument is a [start delta n] description or
% a struct with fields start, step, numberSamples,
% it is  expanded to an actual list of wavelengths.
% 
% A passed list of wavelengths is left alone.
%
% 7/27/02  dhb  Handle struct format too by calling MakeItS first.

S = MakeItS(S);
wls = SToWls(S);
