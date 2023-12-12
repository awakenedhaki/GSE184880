# Load libraries
library(here)
library(readr)
library(dplyr)
library(Seurat)

# Declare paths
DATA <- here("data")
RAW_DATA <- here("data", "raw")

# Load data
sample_metadata <- read_csv(here(DATA, "sample_metadata.csv"))

# Sample directories
sample_dirs <- list.dirs(RAW_DATA, recursive = FALSE, full.names = TRUE)

# Create + Save Seurat objects
seurat_objects <- lapply(sample_dirs, \(sample_dir) {
  message("Processing: ", sample_dir)
  
  # Load counts matrix
  counts <- Read10X(data.dir = sample_dir)
  
  # Gather sample-specific metadata
  accession_number <- basename(sample_dir)
  sample_specific_metadata <- sample_metadata |>
    filter(geo_accession == accession_number)
  
  # Create Seurat object
  message("\tCreating Object")
  seurat_object <- CreateSeuratObject(counts = counts, 
                                      min.cells = 10,
                                      min.features = 500,
                                      project = accession_number)
  
  # Add sample-specific metadata
  # . Preserve barcodes
  seurat_object@meta.data$barcodes <- rownames(seurat_object@meta.data)
  
  # . Add sample-specific metadata
  seurat_object@meta.data <- left_join(
    seurat_object@meta.data, 
    sample_specific_metadata, 
    by = join_by(orig.ident == geo_accession),
    relationship = "many-to-one"
  )
  # . Set metadata row names as barcodes
  rownames(seurat_object@meta.data) <- seurat_object@meta.data$barcodes
  
  # Append unique identifier to cell names (columns)
  barcodes <- colnames(seurat_object)
  colnames(seurat_object) <- paste(seurat_object@project.name, barcodes, sep = "_")
  
  # Save Seurat object
  message("\tSaving Object as RDS")
  saveRDS(seurat_object,
          file = here(DATA, "seurat_objects", paste0(accession_number, ".rds")))
  
  return(seurat_object)
})

message("Merging Seurat Objects")
combined_objects <- merge(seurat_objects[[1]], seurat_objects[-1], project = "GSE184880")

# Save combined Seurat object
saveRDS(combined_objects, file = here(DATA, "GSE184880.rds"))

