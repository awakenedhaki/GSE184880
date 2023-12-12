# Load libraries
library(here)
library(readr)
library(GEOquery)

# Get data/raw/ absolute path
RAW_DATA <- here("data", "raw")

# Load sample metadata using GEOquery
gse <- getGEO("GSE184880", GSEMatrix = TRUE)
gse <- gse[[1]]

# Extract sample metadata
sample_metadata <- pData(phenoData(gse))

# Select relevant columns
columns <- c(
  "geo_accession" = "geo_accession", 
  "tissue_type"   = "tissue type:ch1", 
  "pathology"     = "pathology:ch1",
  "stage"         = "tumor stage:ch1", 
  "age"           = "characteristics_ch1"
)
pruned_sample_metadata <- sample_metadata[columns]

# Rename columns
colnames(pruned_sample_metadata) <- names(columns)

# Save sample metadata
write_csv(pruned_sample_metadata, here("data", "sample_metadata.csv"))

         