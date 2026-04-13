############################################################
## Example R code for genotype QC, gene extraction,
## and VCF export using PLINK2 in UK Biobank RAP
############################################################

source("scripts/00_setup_plink_dx.R")

plink2 <- setup_plink2()
setwd("/home/rstudio-server")

# Replace these example values with the chromosome / gene of interest.
base_bfile <- "/mnt/project/ukb22418_c16_b0_v2"
gene_range_file <- "MPG.txt"
filtered_prefix <- "ukb22418_c16_b0_v2_filt"
selected_prefix <- "Selected_genes_chr16_MPG"
vcf_prefix <- "MPG_vcf"

# Step 1. Apply basic QC filters.
system2(plink2, c(
  "--bfile", base_bfile,
  "--geno", "0.1",
  "--maf", "0.01",
  "--hwe", "1e-15",
  "--make-bed",
  "--out", filtered_prefix
))

# Step 2. Extract the target gene region.
system2(plink2, c(
  "--bfile", filtered_prefix,
  "--extract", "range", gene_range_file,
  "--make-bed",
  "--out", selected_prefix
))

# Step 3. Download and unpack the GRCh38 reference FASTA if needed.
fasta_gz <- "Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz"
fasta_url <- paste0(
  "https://ftp.ensembl.org/pub/current_fasta/homo_sapiens/dna/",
  fasta_gz
)

if (!requireNamespace("R.utils", quietly = TRUE)) {
  stop("Please install the R.utils package before running this script.")
}

if (!file.exists(fasta_gz)) {
  download.file(fasta_url, destfile = fasta_gz, mode = "wb")
}

fasta_path <- sub("\.gz$", "", fasta_gz)
if (!file.exists(fasta_path)) {
  R.utils::gunzip(fasta_gz, overwrite = TRUE)
}

# Step 4. Export the selected dataset to VCF.
system2(plink2, c(
  "--bfile", selected_prefix,
  "--ref-from-fa", fasta_path,
  "--export", "vcf", "id-delim=:",
  "--out", vcf_prefix
))

# Optional upload example:
# upload_to_rap(c(paste0(selected_prefix, c(".bed", ".bim", ".fam")),
#                 paste0(vcf_prefix, ".vcf")),
#               destination = "/LD")
