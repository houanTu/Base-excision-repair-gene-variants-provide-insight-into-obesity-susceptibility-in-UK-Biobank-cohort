############################################################
## Example R code for single-gene screening models
## for obesity-related phenotypes in UK Biobank
############################################################

library(dplyr)
library(car)

df <- readRDS("/home/rstudio-server/merged_data.rds")
df$Birth <- as.numeric(df$Birth)

ids_to_remove <- read.csv("/mnt/project/w71219_20250818.csv", header = FALSE)
id_list <- ids_to_remove$V1
df <- df[!(df$ID %in% id_list), ]

genes <- c(
  "FEN1_vcf", "output_chr16_FTO_remove_ld", "LIG3_vcf", "LIG1_vcf",
  "TDG_vcf", "UNG_vcf", "MPG_vcf", "output_chr10_MGMT_remove_ld",
  "output_chr14_MLH3_remove_ld", "NTHL1_vcf", "XRCC1_vcf",
  "output_chr12_SMUG1_remove_ld", "MUTYH_vcf", "PARP1_vcf",
  "NEIL3_vcf", "NEIL2_vcf", "output_chr8_POLB_remove_ld",
  "MLH1_vcf", "OGG1_vcf"
)

df[genes] <- lapply(df[genes], function(x) as.numeric(as.character(x)))

run_gene_models <- function(data, genes, formula_string, file_prefix) {
  sink(paste0(file_prefix, ".txt"))

  results_df <- data.frame(
    Gene = character(0),
    PValue = numeric(0),
    Adj_R2 = numeric(0)
  )

  for (gene in genes) {
    cat("### Results for gene:", gene, "###
")
    full_formula <- as.formula(paste(formula_string, "+", gene))
    m <- lm(full_formula, data = data)

    adj_r2 <- summary(m)$adj.r.squared
    p_val <- summary(m)$coefficients[gene, "Pr(>|t|)"]
    anova_res <- Anova(m, type = "III")

    results_df <- rbind(
      results_df,
      data.frame(Gene = gene, PValue = p_val, Adj_R2 = adj_r2)
    )

    print(summary(m))
    print(anova_res)
    cat("
Adjusted R2:", adj_r2, "

")
  }

  sink()
  write.table(results_df, paste0(file_prefix, "_summary.txt"), sep = "	", row.names = FALSE)
}

# Example BMI screening model.
run_gene_models(
  data = df,
  genes = genes,
  formula_string = "BMI ~ Sex + Age + log(1 + MET) + Smoking + Qualif_Simplified",
  file_prefix = "single_gene_BMI_model"
)
