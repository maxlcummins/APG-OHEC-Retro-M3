# Supplementary Table 1: one row per genome, joining the published M1
# supplementary metadata to the current manuscript's analysis results.
reference <- readxl::read_xlsx(
  require_input(analysis_inputs$m1_supplementary_reference),
  sheet = "Metadata", col_types = "text", na = c("", "NA")
)

if (anyDuplicated(reference$name) || anyDuplicated(genometa$name) ||
    !setequal(reference$name, genometa$name)) {
  stop("M1 reference and analysis metadata must have the same unique sample IDs.")
}

markers <- genometa %>%
  transmute(name,
            Phylogroup = Consensus_phylogroup,
            `ColV marker genes detected` = as.integer(ColV == 1),
            `senB detected` = as.integer(ABRICATE..vfdb_senB == 1),
            `HPI all 11 markers detected` = as.integer(if_all(all_of(hpi_marker_columns), ~ .x == 1)),
            `stx detected` = as.integer(ABRICATE..vfdb_stx1A == 1 |
              ABRICATE..vfdb_stx1B == 1 | ABRICATE..vfdb_stx2A == 1 |
              ABRICATE..vfdb_stx2B == 1 | ABRICATE..vfdb_stxA == 1),
            `intI1 detected` = as.integer(ABRICATE..EC_custom_intI1_HQ730118.1 == 1),
            `Potential HyPEC` = as.integer(name %in% potential_hybrids$name))

# Virulence names come from the same normalised calls used in the analysis.
virulence_calls <- virulence_df_for_plot %>%
  filter(!is.na(GENE), !is.na(name)) %>% distinct(name, GENE) %>%
  group_by(name) %>% summarise(`Virulence genes detected` = paste(sort(unique(GENE)), collapse = "; "), .groups = "drop")

pathotype_calls <- focused_VFs %>%
  filter(!is.na(pathotype), !is.na(name)) %>% distinct(name, pathotype) %>%
  mutate(detected = 1L) %>%
  pivot_wider(names_from = pathotype, values_from = detected, values_fill = 0, names_prefix = "Pathotype markers ")

core_amr <- amrfinder %>%
  filter(Scope == "core", `Element type` == "AMR", `Element subtype` == "AMR") %>%
  distinct(name, `Gene symbol`) %>%
  group_by(name) %>% summarise(`AMR genes detected core` = paste(sort(unique(`Gene symbol`)), collapse = "; "), .groups = "drop")

qrdr <- amrfinder %>%
  filter(`Element subtype` == "POINT", `Gene symbol` %in% established_qrdr) %>%
  distinct(name, `Gene symbol`) %>%
  group_by(name) %>% summarise(`Established QRDR substitutions` = paste(sort(unique(`Gene symbol`)), collapse = "; "), .groups = "drop")

supplementary_table_1 <- reference %>%
  left_join(markers, by = "name") %>%
  left_join(pathotype_calls, by = "name") %>%
  left_join(cohort_amr_summary %>% select(name, n_AMR, n_classes, MDR, CIA), by = "name") %>%
  left_join(count_of_amr_classes %>% select(name, Count_of_AMR_classes), by = "name") %>%
  left_join(virulence_calls, by = "name") %>%
  left_join(core_amr, by = "name") %>%
  left_join(qrdr, by = "name") %>%
  mutate(across(starts_with("Pathotype markers "), ~ replace_na(.x, 0L))) %>%
  rename(`Sample name` = name,
         `Strain name (published)` = strain_name,
         `Sequence type (published)` = ST,
         `Source niche` = Revised_Source_Niche, `Source type` = Revised_Source_Type,
         `Isolation site category` = Intestinal_or_Extraintestinal,
         `BioSample accession` = `Biosample number`,
         `Sequence run accession` = `SRA Accession`, `BioProject accession` = `Bio Project ID`,
         `Collection year` = Collection_Year, `State (published)` = State,
         `IncF RST` = IncF_RST,
         `AMR gene count core` = n_AMR, `AMR class count core` = n_classes,
         `MDR core class rule` = MDR, `CIA selected gene and subclass rule` = CIA,
         `AMR class count XDR rule` = Count_of_AMR_classes)

if (nrow(supplementary_table_1) != nrow(reference) || anyDuplicated(supplementary_table_1$`Sample name`)) {
  stop("Supplementary Table 1 must contain one row per reference sample.")
}
readr::write_tsv(supplementary_table_1, figure_path("Supplementary_Table_1.tsv"), na = "NA")
source("R/06_supplementary_workbook.R", local = TRUE)
