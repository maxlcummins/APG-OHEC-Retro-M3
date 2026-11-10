# Prepare genotype calls for downstream virulence and IS analyses.
# Read in our genotype data
genotype <- read_delim(genotype_input(), 
    delim = "\t", escape_double = FALSE, 
    trim_ws = TRUE)

# Remove fasta from end of name
genotype <- genotype %>% mutate(name = str_replace(name, '.fasta', ''))

# Remove genomes not present in sample names
genotype <- genotype %>% filter(name %in% sample_names$name)

# Remove genomes which dont meet our thresholds
genotype <- genotype %>% filter(`%COVERAGE` >= coverage_threshold & `%IDENTITY` >= identity_threshold)

# Add a column for present
genotype <- genotype %>% mutate(Present = 1)
