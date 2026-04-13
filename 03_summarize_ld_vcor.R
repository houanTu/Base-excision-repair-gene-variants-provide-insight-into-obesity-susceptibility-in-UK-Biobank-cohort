############################################################
## Example R code for summarizing PLINK LD .vcor files
############################################################

vcor_dir <- "/mnt/project/LD"
out_dir <- "/home/rstudio-server/LD_results"

if (!dir.exists(out_dir)) {
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
}

vcor_files <- list.files(vcor_dir, pattern = "\.vcor$", full.names = TRUE)
cat("Found", length(vcor_files), ".vcor files.
")

results <- data.frame(
  file = basename(vcor_files),
  has_data = logical(length(vcor_files)),
  stringsAsFactors = FALSE
)

for (i in seq_along(vcor_files)) {
  lines <- readLines(vcor_files[i], warn = FALSE)
  results$has_data[i] <- length(lines) > 1
}

write.csv(results, file.path(out_dir, "ld_results_summary.csv"), row.names = FALSE)
print(results)

# Optional upload example:
# system("dx upload /home/rstudio-server/LD_results/ld_results_summary.csv --path /LD_summary")
