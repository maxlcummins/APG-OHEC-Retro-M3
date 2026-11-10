# Paths are relative to the project root (set by the R Markdown setup chunk).
analysis_inputs <- list(
  metadata = "delims/genometa_analysis.tsv.gz",
  metadata_full = "delims/genometa_n5471.txt",
  m1_supplementary_reference = "data/reference/M1_published_Supp_Table_1.xlsx",
  collection_tree = "analysis/RapidNJ_5471.nwk",
  resistance = "analysis/amrfinder_raw.txt",
  genotype = "analysis/genotyping_Nov_2024/genotype.txt",
  genotype_gz = "analysis/genotyping_Nov_2024/genotype.txt.gz",
  xdr_tree = "analysis/XDR_mashtree.dnd",
  hybrid_tree = "analysis/HyPEC_mashtree.dnd",
  cgmlst = "analysis/cgMLST_dists_5471.txt",
  cgmlst_gz = "analysis/cgMLST_dists_5471.txt.gz"
)

require_input <- function(path) {
  if (!file.exists(path)) {
    stop("Required analysis input not found: ", path, call. = FALSE)
  }
  path
}

cgmlst_input <- function() {
  if (file.exists(analysis_inputs$cgmlst)) return(analysis_inputs$cgmlst)
  require_input(analysis_inputs$cgmlst_gz)
}

genotype_input <- function() {
  if (file.exists(analysis_inputs$genotype)) return(analysis_inputs$genotype)
  require_input(analysis_inputs$genotype_gz)
}

# Set M3_FIGURE_DIR to redirect generated figures, for example during checks.
figure_path <- function(name) {
  root <- Sys.getenv("M3_FIGURE_DIR", unset = "figures/generated")
  path <- file.path(root, name)
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  path
}
