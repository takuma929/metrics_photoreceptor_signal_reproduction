# Vendored Psychtoolbox-3 functions

The files in this directory are copied **verbatim** from
[Psychtoolbox-3](https://github.com/Psychtoolbox-3/Psychtoolbox-3)
(version 3.0.18, module `PsychColorimetric`). They are bundled here so that
this toolbox runs without requiring a separate Psychtoolbox installation.

Only an attribution header (a comment block) was prepended to each `.m` file;
the function code itself is unmodified.

## Files and why they are needed

| File | Used by | Purpose |
|---|---|---|
| `SplineSpd.m` | `plot_figure1` | Resample a spectral power distribution onto a new wavelength grid (power-per-band convention). |
| `SplineRaw.m` | `SplineSpd` | Underlying spline/linear resampling. |
| `MakeItWls.m` | `SplineRaw` | Expand a `[start delta n]` spec to a wavelength list. |
| `MakeItS.m` | `SplineSpd`, `SToWls` | Coerce a wavelength description to `[start delta n]` (S) format. |
| `SToWls.m` | `MakeItWls`, `WlsToS` | Expand an S vector to an explicit wavelength list. |
| `WlsToS.m` | `MakeItS` | Convert a wavelength list back to S format. |
| `GenerateCIEDay.m` | `plot_figure2` | Generate CIE daylight SPDs from correlated colour temperature. |
| `B_cieday.mat` | `plot_figure2` | CIE daylight basis vectors (S0, S1, S2) consumed by `GenerateCIEDay`. |

These seven functions form the complete transitive dependency closure of the
two Psychtoolbox calls that remained in the toolbox (`SplineSpd` in
`plot_figure1` and `GenerateCIEDay` in `plot_figure2`). No other Psychtoolbox
functionality is used.

## License

Psychtoolbox-3 is distributed under the MIT License for material outside its
`PsychContributed` folder (which these files are). The applicable copyright is:

> Copyright (c) 1996–2018 David Brainard and the individual Psychtoolbox core
> developers (David Brainard, Denis Pelli, Allen Ingling, Mario Kleiner, and
> contributors).
>
> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files (the "Software"), to deal
> in the Software without restriction, including without limitation the rights
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
> copies of the Software, and to permit persons to whom the Software is
> furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in all
> copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> SOFTWARE.

The MIT License is compatible with this repository's own MIT License.

## Full source

The complete Psychtoolbox-3 distribution and its full licensing text are at
<https://github.com/Psychtoolbox-3/Psychtoolbox-3>.
