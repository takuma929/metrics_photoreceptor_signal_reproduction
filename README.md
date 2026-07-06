# PhotoSim — physiologically relevant display reproduction metrics

MATLAB toolbox for quantifying how faithfully a display reproduces the **α‑opic
quintuplet** — the signals of the L‑, M‑, and S‑cones, the rods, and the
melanopsin‑containing ipRGCs — from real‑world light.

It implements the two metrics and the visualization introduced in the paper:

- **PSRM** (Photoreceptor Signal Reproduction Metric): the fraction of real‑world
  α‑opic quintuplets a display can reproduce without distortion.
- **PSDM** (Photoreceptor Signal Distortion Metric): the distortion introduced
  when a display with fewer than five primaries reproduces a quintuplet, reported
  overall or per photoreceptor.
- **Equal‑luminance photoreceptor excitation diagram**: an extension of the
  MacLeod–Boynton chromaticity diagram to all five photoreceptor signals.

## Requirements

- MATLAB (developed and tested with R2025b). No MathWorks add‑on toolboxes
  beyond base MATLAB are required.
- `data/data.mat` — the single consolidated data store, bundled with the repo.

No external toolbox installation is needed. The handful of
[Psychtoolbox](http://psychtoolbox.org/) colour utilities the code relies on
(`SplineSpd`, `GenerateCIEDay`, and their dependencies) are bundled, verbatim
and with attribution, under [`src/functions/psychtoolbox/`](src/functions/psychtoolbox/)
— see its [`NOTICE.md`](src/functions/psychtoolbox/NOTICE.md). If you happen to
have Psychtoolbox on your path as well, the bundled copies are identical, so
either resolves.

## Reproducibility / computing environment

The results and figures were produced and verified on the following environment:

| Component | Version |
|---|---|
| Operating system | macOS 26.5.1 (build 25F80) |
| MATLAB | R2025b |
| Bundled Psychtoolbox utilities | 3.0.18 (vendored, see below) |

`main` adds `src/` (recursively) to the path, which includes the bundled
Psychtoolbox colour utilities under
[`src/functions/psychtoolbox/`](src/functions/psychtoolbox/); no separate
Psychtoolbox install is required. No MathWorks add‑on toolboxes beyond base
MATLAB are needed.

Notes for reproducing the results (e.g. for a [CODECHECK](https://codecheck.org.uk/)):

- **What to run.** From the repository root, run `main` (see *Quick start*). This
  rebuilds the metrics from the bundled `data/data.mat` and redraws every paper
  figure into `figs/`. The regenerated files are listed as the *manifest* in
  [`codecheck.yml`](codecheck.yml).
- **Runtime.** The default `main` run (metrics for the main reference set at all
  four bit depths + all figures) completes in the order of minutes on a modern
  laptop. The optional supporting analyses, `main(true, true)`, are noticeably
  slower and are only needed to regenerate the Table values.
- **`data/data.mat` is an input, not an output.** It is bundled and should not
  be regenerated; the data‑preparation scripts that overwrite it
  (`build_data_mat`, `build_main_illuminants`, `run_asano_cie2006`) are *not*
  called by `main` and should not be run for a reproduction.
- **The external SpectroSense dataset is not required.** The ~25 GB figshare
  download (see *External data* below) is used only for a supplementary
  robustness check and is not needed to reproduce the main results or any of the
  manifest figures.

## Quick start

From the repository root, in MATLAB:

```matlab
main            % rebuild all databases + metrics, then redraw every figure
```

Other entry points:

```matlab
main(false)         % reuse existing results/*.mat, only redraw the figures
main(true, true)    % also rerun the supporting (Table) analyses (slow)
```

`main` performs three stages:

1. **`run_all_photosim`** — builds the reference database and computes the
   metrics for the naturalistic reference set at infinite, 12‑, 10‑, and 8‑bit
   display resolution (written to `results/`).
2. **Supporting analyses** *(optional)* — inter‑observer variability
   (`run_individual_observer_metrics`) and luminance weighting
   (`run_luminance_weighted_metrics`), which produce the Table values.
3. **Figures** — every paper figure is redrawn into `figs/`.

## Reference set

The main analyses use a curated main reference set of 183 illuminants — 65 CIE
daylight phases (4000–20000 K) plus 118 measured real‑world illuminants that pass
a broadcast‑quality fidelity screen (ANSI/IES TM‑30‑18 `Rf ≥ 85`, `Rg ≥ 90`) —
combined with the 99 IES TM‑30 reflectances, giving 18,117 radiance spectra. The
metrics are not tied to this set; any collection of real‑world spectra can be
supplied instead.

## Repository layout

```
main.m                     one‑click wrapper (regenerate everything)
data/
  data.mat                 consolidated data store (loaded via load_data)
  28176839/                SpectroSense measured spectra (external, see below)
src/
  functions/               core reusable functions (get_psrm, get_psdm, ...)
    tm30/                   pure‑MATLAB ANSI/IES TM‑30‑18 implementation
  analysis/                pipeline & analysis scripts (run_all_photosim, ...)
  plotting/                plot_figure1 … plot_figure9
results/                   generated metric/reference databases (not tracked)
figs/                      generated figures (not tracked)
```

All source is location‑independent: every script derives its own paths, so the
scripts run from any working directory.

## External data

The real‑world **SpectroSense** spectra used for the robustness check are not
bundled (>25 GB). Download them from figshare
(https://doi.org/10.6084/m9.figshare.28176839); the download is a folder named
`28176839`. Place that folder as‑is directly under `data/`, so the spectra end
up at `data/28176839/SpectroSense Dataset`. Source: Lazar et al., *Regulation of
pupil size in natural vision across the human lifespan*, R. Soc. Open Sci.
**11**(6), 191613 (2024).

## Citing

If you use this toolbox, please cite the paper. The preprint is:

> A. C. Schneider, T. Morimoto, H. E. Smithson, and M. Spitschan, "Beyond colour
> gamuts: Novel metrics for the reproduction of photoreceptor signals," bioRxiv
> (2021). https://doi.org/10.1101/2021.02.27.433203

## Authors

The PhotoSim toolbox was first developed by ACS and modified by TM.

## License

Released under the MIT License. See [LICENSE](LICENSE).
