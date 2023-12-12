# Download the GSE184880 data from GEO into the data/ directory

# `wget` parameters
# . Data retrieval
output_dir="data/"
output_name="GSE184880.tar"
URL="https://www.ncbi.nlm.nih.gov/geo/download/?acc=GSE184880&format=file"

# . Logging
log_dir="log/"
log_name="${log_dir}/download.log"

# Ensure the output and log directories exist
mkdir -p $output_dir
mkdir -p $log_dir

# Check if log file exists, create it if it doesn't
if [ ! -f $log_name ]; then
    touch $log_name
fi

# Get GSE184880 data
wget -v -O "${output_dir}${output_name}" $URL 2>&1 | tee $log_name