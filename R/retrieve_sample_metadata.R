# Load libraries
library(here)
library(dplyr)
library(readr)
library(readxl)
library(GEOquery)

# Get data/raw/ absolute path
DATA <- here("data")
RAW_DATA <- here(DATA, "raw")

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

# Remove "age: " prefix
pruned_sample_metadata$age <- 
  as.double(gsub("age: ", "", pruned_sample_metadata$age))

# Load supplementary table 1 from article
supplementary_table_1 <- read_excel(here(DATA, "supplementary_table_1.xlsx"), skip = 1)

colnames(supplementary_table_1) <- 
  gsub(x = tolower(colnames(supplementary_table_1)), 
       pattern = " ", 
       replacement = "_")

supplementary_table_1 <- supplementary_table_1[,colnames(supplementary_table_1) != "sample"]

# Merge GSE184880 sample metadata with supplementary table 1
merged_metadata <- left_join(
  pruned_sample_metadata, 
  supplementary_table_1,
  by = join_by(age == age,
               stage == tumor_stage,
               pathology == pathology)
)

# Save sample metadata
write_csv(merged_metadata, here(DATA, "sample_metadata.csv"))

         