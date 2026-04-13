############################################################
## Example R code for merging phenotype and genotype data,
## simplifying covariates, filtering outliers, and deriving OCS
############################################################

library(dplyr)
library(tidyr)
library(psych)

pheno <- readRDS("/home/rstudio-server/cleaned_pheno.rds")
geno <- read.csv("/mnt/project/all_genes_risk_scores.csv")

df <- merge(pheno, geno, by.x = "ID", by.y = "X")
print(colSums(is.na(df)))

df <- df %>%
  mutate(
    Qualif_Simplified = case_when(
      grepl("College|University", Qualif) ~ "University",
      grepl("NVQ|HND|HNC|professional", Qualif) ~ "Technical/Vocational",
      grepl("A levels|O levels|GCSEs|CSEs", Qualif) ~ "High School or Secondary",
      grepl("None of the above", Qualif) ~ "None",
      TRUE ~ NA_character_
    ),
    Qualif_Simplified = as.factor(Qualif_Simplified)
  ) %>%
  select(-Qualif)

remove_outliers_iqr <- function(x) {
  q1 <- quantile(x, 0.25, na.rm = TRUE)
  q3 <- quantile(x, 0.75, na.rm = TRUE)
  iqr <- q3 - q1
  lower <- q1 - 1.5 * iqr
  upper <- q3 + 1.5 * iqr
  x[x >= lower & x <= upper]
}

# Apply the final phenotype filtering retained in the working analysis.
for (var in c("BMI", "Fat", "WHR")) {
  df[[var]][!df[[var]] %in% remove_outliers_iqr(df[[var]])] <- NA
}

df <- df[complete.cases(df[, c("BMI", "Fat", "WHR")]), ]

df <- df %>%
  mutate(
    z_BMI = scale(BMI)[, 1],
    z_WHR = scale(WHR)[, 1],
    z_Fat = scale(Fat)[, 1],
    OCS = z_BMI + z_WHR + z_Fat
  ) %>%
  select(-z_BMI, -z_WHR, -z_Fat)

if ("MET" %in% names(df)) {
  df$MET[!df$MET %in% remove_outliers_iqr(df$MET)] <- NA
}

cat("Population description:
")
print(prop.table(table(df$Sex)))
print(prop.table(table(df$Income)))
print(prop.table(table(df$Qualif_Simplified)))
print(prop.table(table(df$Smoking)))

numeric_cols <- sapply(df, is.numeric)
print(describe(df[, numeric_cols]))

saveRDS(df, "/home/rstudio-server/merged_data.rds")
cat("Saved /home/rstudio-server/merged_data.rds
")
