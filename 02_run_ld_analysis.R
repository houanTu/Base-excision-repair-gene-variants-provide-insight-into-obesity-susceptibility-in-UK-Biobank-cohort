############################################################
## Example R code for LD analysis of gene-specific PLINK files
############################################################

source("scripts/00_setup_plink_dx.R")

plink2 <- setup_plink2()
input_dir <- "/mnt/project"
out_dir <- choose_output_dir(
  preferred = "/home/rstudio-server/LD_results",
  fallback = "/tmp/LD_results"
)

# Modify this pattern to match the target chromosome or gene subset.
bed_pattern <- "^Selected_genes_chr11_.*\.bed$"

bed_files <- list.files(input_dir, pattern = bed_pattern, full.names = TRUE)
cat("Detected", length(bed_files), "BED files for LD analysis.
")

for (bed_path in bed_files) {
  base_name <- tools::file_path_sans_ext(basename(bed_path))
  bfile_prefix <- file.path(input_dir, base_name)
  out_prefix <- file.path(out_dir, paste0("ld_results_", base_name))

  args <- c(
    "--bfile", bfile_prefix,
    "--r2-phased",
    "--ld-window-r2", "0.8",
    "--ld-window-kb", "999999999",
    "--out", out_prefix
  )

  cat("Running LD analysis for", base_name, "
")
  status <- system2(plink2, args = args)

  if (status != 0) {
    warning("PLINK2 failed for ", base_name, " (exit code ", status, ").")
  }
}

# Optional upload example:
# upload_to_rap(list.files(out_dir, pattern = "\.(vcor|log)$", full.names = TRUE),
#               destination = "/LD")
