# Extract MTXt and TSV files from the TAR data file retrieved from GEO

# Command Parameters
# . Directory paths
host_dir="data/"
target_directory="${host_dir}raw/"

# . Filenames and patterns
tar_filename="GSE184880.tar"
tar_filepath="${host_dir}${tar_filename}"
file_pattern="GSM.*"  # Pattern to match the files to be moved

# . Logging
log_dir="log/"
log_name="${log_dir}/extract.log"

# Ensure the raw directory exist
mkdir -p $target_directory

# Check if log file exists, create it if it doesn't
if [ ! -f $log_name ]; then
    touch $log_name
fi

# Commands
# . Extract files from TAR
tar -xvf $tar_filepath -C $host_dir \
  | tee -a $log_name

# . Move matching files to the target directory
ls $host_dir \
  | grep $file_pattern \
  | xargs -I {} mv -v "${host_dir}{}" $target_directory 2>&1 \
  | tee $log_name

# Loop over each file that matches the pattern in the specified directory
find "$target_directory" -maxdepth 1 -type f -name "GSM*.gz" \
  | while read -r file; do
      # Extract the sample accession nunber from the file name
      sample_accession_number=$(basename "$file" | grep -o 'GSM[0-9]*')
  
      # Create a directory for this pattern if it doesn't exist
      mkdir -p "${target_directory}/${sample_accession_number}"
  
      # Move files with this pattern to the corresponding directory
      mv "$file" "${target_directory}/${sample_accession_number}/"
  done