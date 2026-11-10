# Analysis stage extracted from manuscript_analysis.Rmd.

#Read in amrfinder data
amrfinder <- read_delim(require_input(analysis_inputs$resistance), 
    delim = "\t", escape_double = FALSE, 
    trim_ws = TRUE,
    show_col_types = FALSE)

#Create a list of samples in our tree
sample_names <- tree$tip.label %>% as.data.frame() %>% rename('name' = '.') %>% mutate(name = str_replace_all(name, "\\'", ''))

#Filter out samples not in the tree, add in those missing from dataframe
amrfinder<- left_join(sample_names, amrfinder)
