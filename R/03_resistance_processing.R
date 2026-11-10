# Analysis stage extracted from Nature_Data_Reports_Dec.Rmd.
#Define our thresholds for coverage and identity
coverage_threshold <- 90
identity_threshold <- 90

# Define genes we want to remove
# Note gene names must match exactly
genes_to_remove <- c("blaEC", "blaEC-5", # This gene is intrinsic to E. coli
                      "mcr-9.1", "mcr-9.2") # This does not confer colistin resistance, only inducible colistin resistance

# Remove genes we don't want
amrfinder <- amrfinder %>% filter(!`Gene symbol` %in% genes_to_remove)

#Create a table of the number of samples in each source and phylogroup
name_source_phylo <- genometa %>%
        dplyr::select(name, Revised_Source_Niche, Consensus_phylogroup) %>%
        group_by(Revised_Source_Niche) %>%
        add_count() %>%
        rename('Count of Source' = n) %>%
        group_by(Consensus_phylogroup) %>%
        add_count() %>%
        rename('Count of Phylogroup' = n) %>%
        ungroup()

# Separate point mutations which are required to have 100% coverage and identity
point_mutations <- amrfinder %>%
        filter(Subclass == "POINT") %>%
        filter(`% Coverage of reference sequence` == 100 & `% Identity to reference sequence` == 100)

# Remove point mutations and anything below identity thresholds
amrfinder <- amrfinder %>%
        filter(Subclass != "POINT") %>%
        filter(`% Coverage of reference sequence` >= coverage_threshold & `% Identity to reference sequence` >= identity_threshold)

# Bind point mutations back in
amrfinder <- bind_rows(amrfinder, point_mutations)

# Add a column to indicate the gene is present
amrfinder <- amrfinder %>% mutate(Present = 1)

# Remove duplicate hits within the same genome, prioritising hits with greater nucleotide identity
amrfinder <- amrfinder %>% arrange(desc(`% Identity to reference sequence`)) %>% group_by(name, `Gene symbol`) %>% slice_head(n = 1) %>% ungroup()

# Give our reporting category
amrfinder <- amrfinder %>%
        # Generate a new column for reported class
        # Signal when genes are point mutation associated
        mutate(Reported_Class = if_else(`Element subtype` == "POINT", paste0(Class, " POINT"), Class)) %>%
        # Change beta-lactams to be the subclass
        mutate(Reported_Class = if_else(Reported_Class == "BETA-LACTAM", Subclass, Reported_Class)) %>%
        # Combine Streptothricin into aminoglycosides
        mutate(Reported_Class = if_else(Reported_Class == "STREPTOTHRICIN", "AMINOGLYCOSIDE", Reported_Class)) %>%
        # Combine Streptothricin into aminoglycosides
        mutate(Reported_Class = if_else(Reported_Class %in% c("FOSMIDOMYCIN", "FOSFOMYCIN"), "PHOSPHONIC ACIDS", Reported_Class))  %>%
        # Combine Streptothricin into aminoglycosides
        mutate(Reported_Class = if_else(Reported_Class %in% c("FOSMIDOMYCIN POINT", "FOSFOMYCIN POINT"), "PHOSPHONIC ACIDS POINT", Reported_Class))

# Generate a table which includes genome names, the class and subclass genes are present for
amrfinder_class_wise <- amrfinder %>%
        dplyr::select(name, `Element type`, `Element subtype`, Reported_Class, Present) %>%
        separate_rows(Reported_Class, sep = "/") %>%
        unique()

# Established fluoroquinolone resistance-associated QRDR substitutions
established_qrdr <- c(
  "gyrA_G81C", "gyrA_S83A", "gyrA_S83L", "gyrA_S83V",
  "gyrA_D87N", "gyrA_D87Y", "parC_G78C", "parC_S80I",
  "parC_S80R", "parC_E84G", "parC_E84K", "parC_E84V"
)
