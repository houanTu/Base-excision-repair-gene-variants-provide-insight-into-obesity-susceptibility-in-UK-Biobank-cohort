############################################################
## Example R code for preparing simplified VCF files
## for downstream annotation tools such as snpEff
############################################################

out_dir <- "/home/rstudio-server/new_vcf"
if (!dir.exists(out_dir)) {
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
}

input_vcf <- "/mnt/project/output_chr16_FTO_remove_ld.vcf"
truncated_vcf <- file.path(out_dir, "Variant_annotation_output_chr16_FTO_remove_ld.vcf")
final_vcf <- file.path(out_dir, "Variant_annotation_output_chr16_FTO_remove_ld_final.vcf")

# Keep only the first five core VCF columns.
cmd_cut <- sprintf("cut -f1-5 %s > %s", shQuote(input_vcf), shQuote(truncated_vcf))
system(cmd_cut)

# Add placeholder QUAL, FILTER, and INFO fields.
cmd_awk <- sprintf(
  "awk 'BEGIN{OFS="\t"} /^#/ {print; next} !/^#/ {print $1,$2,$3,$4,$5,250,"PASS","."}' %s > %s",
  shQuote(truncated_vcf),
  shQuote(final_vcf)
)
system(cmd_awk)

# Helper to restore a valid VCF header when needed.
fix_vcf_header <- function(vcf_path, output_path = basename(vcf_path)) {
  x <- readLines(vcf_path)
  new_header <- "#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO"
  last_meta <- max(grep("^##", x))
  x <- append(x, new_header, after = last_meta)
  x <- x[!grepl("^#CHROM\s+POS\s+ID\s+REF\s+ALT$", x)]
  writeLines(x, output_path)
}

# Example usage:
# fix_vcf_header("/mnt/project/Variant_annotation_NTHL1_final.vcf",
#                "/home/rstudio-server/Variant_annotation_NTHL1_final.vcf")
