############################################################
## Example R code for computing per-gene allele-burden scores
## from VCF files using PLINK2 --export A
############################################################

source("scripts/00_setup_plink_dx.R")

plink2 <- setup_plink2()
setwd("/home/rstudio-server")

# This text file should contain one VCF filename per line.
file_list <- readLines("list_beds.txt")
file_list <- file_list[nzchar(file_list)]

all_risk_scores <- list()
sample_ids <- NULL

for (vcf_file in file_list) {
  vcf_path <- file.path("/mnt/project", vcf_file)
  if (!file.exists(vcf_path)) {
    stop("VCF not found: ", vcf_path)
  }

  gene_name <- sub("\.vcf(\.gz)?$", "", basename(vcf_file))
  out_prefix <- paste0("tmp_", gene_name)

  system2(plink2, c(
    "--vcf", vcf_path,
    "--export", "A",
    "--out", out_prefix
  ))

  raw_file <- paste0(out_prefix, ".raw")
  if (!file.exists(raw_file)) {
    stop("Expected PLINK raw file was not created: ", raw_file)
  }

  df <- read.table(raw_file, header = TRUE, check.names = FALSE)

  # Harmonize IDs when PLINK exports compound identifiers.
  df$IID <- sub("[:_].*$", "", df$IID)

  non_geno_cols <- c("FID", "IID", "PAT", "MAT", "SEX", "PHENOTYPE")
  geno_cols <- setdiff(colnames(df), non_geno_cols)

  if (length(geno_cols) == 0) {
    stop("No genotype columns were detected in ", raw_file)
  }

  geno_mat <- df[, geno_cols, drop = FALSE]
  risk_scores <- rowSums(geno_mat, na.rm = TRUE)
  names(risk_scores) <- df$IID

  if (is.null(sample_ids)) {
    sample_ids <- df$IID
  } else {
    if (!setequal(sample_ids, df$IID)) {
      stop("Sample IDs are inconsistent across genes.")
    }
    risk_scores <- risk_scores[sample_ids]
  }

  all_risk_scores[[gene_name]] <- risk_scores
}

final_scores <- as.data.frame(all_risk_scores, check.names = FALSE)
rownames(final_scores) <- sample_ids

write.csv(final_scores, "all_genes_risk_scores.csv", row.names = TRUE)
cat("Finished writing all_genes_risk_scores.csv
")

# Optional upload example:
# system("dx upload /home/rstudio-server/all_genes_risk_scores.csv --path /")
