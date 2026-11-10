# Analysis stage extracted from Nature_Data_Reports_Dec.Rmd.

genometa <- vroom(require_input(analysis_inputs$metadata), show_col_types = FALSE)

# The published M1 workbook is the source of sequence types throughout the
# analysis. Non-numeric entries are retained in the supplement but are not
# assigned an ST for grouping or ranking.
published_st <- readxl::read_xlsx(
        require_input(analysis_inputs$m1_supplementary_reference),
        sheet = "Metadata", col_types = "text", na = c("", "NA")
) %>%
        transmute(name, published_st = ST)
if (anyDuplicated(published_st$name) || anyDuplicated(genometa$name) ||
    !setequal(published_st$name, genometa$name)) {
        stop("Published metadata and analysis metadata must have the same unique sample IDs.")
}
genometa <- genometa %>%
        select(-ST_new) %>%
        left_join(published_st, by = "name") %>%
        mutate(ST_new = if_else(str_detect(published_st, "^[0-9]+$"),
                                published_st, NA_character_)) %>%
        select(-published_st)

# Make a small metadata sheet for later use
small_meta <- genometa %>%
        dplyr::select(name, Revised_Source_Niche, ST_new, Consensus_phylogroup, `ABRICATE..EC_custom_intI1_HQ730118.1`) %>%
        group_by(Consensus_phylogroup) %>%
        add_count() %>%
        rename(`Count of Phylogroup` = n) %>%
        group_by(Revised_Source_Niche) %>%
        add_count() %>%
        rename(`Count of Source` = n) %>%
        group_by(ST_new) %>%
        add_count() %>%
        rename(`Count of ST` = n) %>%
        rename("Class 1 integrase" = `ABRICATE..EC_custom_intI1_HQ730118.1`) %>%
        ungroup()

# Make a table linking sources to their counts
source_counts_df <- small_meta %>%
        dplyr::select(Revised_Source_Niche, `Count of Source`) %>%
        unique()

# Make a table linking phylogroups to their counts
phylo_counts_df <- small_meta %>%
        dplyr::select(Consensus_phylogroup, `Count of Phylogroup`) %>%
        unique()

#Read in our tree
tree <- ggtree::read.tree(require_input(analysis_inputs$collection_tree))

# Midpoint root our tree
tree <- midpoint_root(tree)

#Remove quotes from sample names
tree$tip.label <- gsub("'", '', tree$tip.label)
tree$tip.label <- gsub("\\.fa", "", tree$tip.label)

#Create a list of samples in our cohort
sample_names <- tree$tip.label %>% as.data.frame() %>% rename('name' = '.')

# Create a list of names and sources
name_source <- genometa %>%
        select(name, Revised_Source_Niche)

# Create a list of names and STs
name_ST <- genometa %>%
        select(name, ST_new) %>%
        mutate(ST_other = fct_lump_n(ST_new, n = 20))

#Read in amrfinder data in long format
#amrfinder_long <- vroom("delims/long_format_amrfinder_5471.txt", show_col_types = FALSE)

