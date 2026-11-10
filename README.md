# Australian E. coli genomic analysis

This repository contains R analyses of genomic, virulence and antimicrobial resistance data for a collection of 5,471 Australian *Escherichia coli* isolates. The active analysis is `markdown/manuscript_analysis.Rmd`. Manuscript Word documents are kept locally and excluded from Git.

## Repository layout

- `R/`: input paths and shared data preparation stages used by the active analysis.
- `markdown/manuscript_analysis.Rmd`: analysis entry point.
- `markdown/sections/`: downstream analysis and plotting sections, run in order by the entry point.
- `analysis/`: analysis inputs. Historical intermediate data are retained locally in the ignored `analysis/maybe_unnecessary/` directory.
- `data/reference/`: published M1 supplementary metadata used for Supplementary Table 1.
- `delims/`: locally supplied genomic metadata and reference tables.
- `figures/`: existing figure files; new generated outputs default to `figures/generated/`.

Older notebooks and plot-generation blocks are kept locally and ignored by Git; they are not part of the active workflow. Legacy figure PDFs are also retained locally but are not tracked. Generated manuscript outputs are written to `figures/generated/`, which is ignored.

## Inputs and setup

The active workflow requires the paths listed in `R/00_inputs.R`. The reduced input `delims/genometa_analysis.tsv.gz` contains only fields used by the active analysis and can be regenerated from the full metadata file `delims/genometa_n5471.txt` with `python3 scripts/prepare_analysis_metadata.py`. Both metadata files are included in the repository. The reduced file retains sample identifiers, source category, state and collection year; it is not anonymised. Other local metadata files remain ignored. The current genotype dataset is `analysis/genotyping/genotype.txt.gz`, which is distinct from the older `analysis/genotype.txt.gz`. The workflow reads the compressed genotype file directly if the ignored expanded copy is absent. The cgMLST distances can likewise be read directly from `analysis/cgMLST_dists_5471.txt.gz`, without expanding or removing the archive. The Roary file is not used by the active workflow.

The verification environment uses R 4.3.3. `renv.lock` records the packages and recursive dependencies captured from the working environment, including Bioconductor 3.18. Restore the library with `renv::restore()`. An isolated restore was tested using a copied package cache and a pre-existing `quantreg` binary; a completely fresh restore on the test Mac stopped when source installation of `quantreg` required a Fortran compiler. Direct package versions from the verification run are also recorded in `R/verification_package_versions.txt`. See `R/README.md` for the stage dependencies.

## Run

From the project root, with the required packages and inputs installed:

```r
rmarkdown::render("markdown/manuscript_analysis.Rmd")
```

The analysis is sequential and can take substantial time and memory. Set `M3_FIGURE_DIR` to a separate directory before running to redirect generated plots, for example:

```r
Sys.setenv(M3_FIGURE_DIR = "/path/to/output/figures")
rmarkdown::render("markdown/manuscript_analysis.Rmd")
```

The workflow exports six figure files using the working order after removal of the ColV–senB–HPI Venn plot. Other generated panels use descriptive filenames. Figure 2 shows exclusive pathotype intersections; the current analysis identifies 736 potential HyPEC genomes. Figure numbering should be checked against the final manuscript before submission.

## Manuscript outputs

| Output | Main analysis code |
| --- | --- |
| Figure 1 — collection overview | `markdown/manuscript_analysis.Rmd` |
| Figure 2 — hybrid pathotypes | `markdown/sections/04_xdr_and_hybrids.Rmd` |
| Figure 3 — hybrid virulence and resistance | `markdown/sections/05_hybrid_tree_and_distances.Rmd` |
| Figure 4 — hybrid allelic distances | `markdown/sections/05_hybrid_tree_and_distances.Rmd` |
| Figure 5 — resistance classes by source | `markdown/sections/01_sourcewise_resistance.Rmd` |
| Figure 6 — XDR resistance classes | `markdown/sections/04_xdr_and_hybrids.Rmd` |
| Table 1 — characteristics by hybrid sequence type | `markdown/sections/06_virulence_figures_and_summary.Rmd` |
| Table 2 — clinically important resistance calls by source | `markdown/sections/06_virulence_figures_and_summary.Rmd` |
| Supplementary Table 1 — per-genome metadata and current genotypes | `R/05_supplementary_table.R` |

These sections share the collection, genotype and resistance inputs prepared by the scripts in `R/`; they are run together by the entry point rather than independently.

Tables 1 and 2 are exported as `Table_1_regenerated.csv` and `Table_2_regenerated.csv` in the generated output directory.

Supplementary Table 1 is exported as both TSV and Excel by the active workflow. The Excel workbook contains genome records, gene calls and definitions, and uses the `openxlsx` R package recorded in the lockfile. Its sample-level metadata start from `data/reference/M1_published_Supp_Table_1.xlsx`, the published M1 supplementary workbook, and are joined by sample ID to the current results. The published table has the same 5,471 unique sample IDs as this analysis. Sequence types throughout the analysis come from that workbook; non-numeric values are displayed as unassigned in Figure 1 and excluded from ST-specific summaries. The supplement retains the published values verbatim. The retained sample IDs and location fields are not anonymised.
