# Active analysis stages

`markdown/manuscript_analysis.Rmd` is the analysis entry point. Run it from the project root; its setup chunk sources these scripts in order into the notebook's execution environment:

- `00_inputs.R`: input paths and checks.
- `01_collection.R`: genomic metadata, tree and isolate-level metadata.
- `02_resistance_input.R`: AMRFinder input and sample join.
- `03_resistance_processing.R`: resistance thresholds, deduplication and reporting categories.
- `04_genotype.R`: genotype calls filtered to the study samples and thresholds.
- `05_supplementary_table.R`: joins the published M1 supplementary workbook to current per-genome results and exports Supplementary Table 1.
- `06_supplementary_workbook.R`: formats the same table as an Excel workbook, using definitions in `data/reference/supplementary_table_definitions.tsv`.

The downstream analyses and plots are in `markdown/sections/`, sourced in order as child documents, and depend on objects produced by earlier stages. These scripts and sections are not independent entry points. The current genotype input in `analysis/genotyping/` is not the same dataset as `analysis/genotype.txt.gz`. For genotype and cgMLST, the notebook reads an expanded local file if present, otherwise it reads the `.gz` directly. The compressed Roary file is not required by this workflow.

The lockfile records the packages and recursive dependencies from the working R 4.3.3 environment. An isolated restore was tested using a copied package cache and a pre-existing `quantreg` binary; source installation of `quantreg` on the test Mac required a Fortran compiler.
