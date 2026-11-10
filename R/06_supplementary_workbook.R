# Format the per-genome TSV as a workbook without changing its data.
gene_columns <- c("Virulence genes detected", "AMR genes detected core",
                  "Established QRDR substitutions")
genome_columns <- setdiff(names(supplementary_table_1), gene_columns)
gene_call_columns <- c("Sample name", gene_columns)
definitions <- readr::read_tsv(
  require_input("data/reference/supplementary_table_definitions.tsv"),
  col_types = readr::cols(.default = readr::col_character()),
  show_col_types = FALSE
)
if (!setequal(definitions$Field[!definitions$Field %in% c("Published source", "Generation code")],
              names(supplementary_table_1))) {
  stop("Supplementary workbook definitions do not match the table columns.")
}

workbook <- openxlsx::createWorkbook(creator = "APG-OHEC-Retro-M3")
header_style <- openxlsx::createStyle(
  fontName = "Arial", fontSize = 10, textDecoration = "bold",
  fontColour = "#FFFFFF", fgFill = "#1F4E78", wrapText = TRUE
)
add_sheet <- function(name, data, table_name, widths, header_height = 45) {
  openxlsx::addWorksheet(workbook, name, gridLines = FALSE)
  openxlsx::writeDataTable(workbook, name, data, tableName = table_name,
                          tableStyle = "TableStyleMedium2", withFilter = TRUE,
                          headerStyle = header_style, keepNA = FALSE)
  openxlsx::freezePane(workbook, name, firstRow = TRUE)
  openxlsx::setRowHeights(workbook, name, rows = 1, heights = header_height)
  openxlsx::setColWidths(workbook, name, cols = seq_along(widths), widths = widths)
}
add_sheet("Genomes", supplementary_table_1[genome_columns], "GenomeRecords",
          pmax(22, pmin(38, nchar(genome_columns))))
add_sheet("Gene calls", supplementary_table_1[gene_call_columns], "GeneCalls",
          c(23, 55, 55, 55))
add_sheet("Definitions", definitions, "FieldDefinitions", c(40, 100, 34))
definition_style <- openxlsx::createStyle(wrapText = TRUE, valign = "center")
openxlsx::addStyle(workbook, "Definitions", definition_style,
                   rows = 2:(nrow(definitions) + 1), cols = 1:3,
                   gridExpand = TRUE, stack = TRUE)
openxlsx::setRowHeights(workbook, "Definitions", rows = 2:(nrow(definitions) + 1), heights = 42)
openxlsx::saveWorkbook(workbook, figure_path("Supplementary_Table_1.xlsx"), overwrite = TRUE)
