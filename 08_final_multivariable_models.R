############################################################
## Example R code for final multivariable models with
## selected BER main effects and interaction terms
############################################################

library(modelsummary)
library(broom)
library(dplyr)
library(sandwich)
library(lmtest)
library(effects)
library(ggplot2)

df <- readRDS("/home/rstudio-server/merged_data.rds")
df$Birth <- as.numeric(df$Birth)

ids_to_remove <- read.csv("/mnt/project/w71219_20250818.csv", header = FALSE)
id_list <- ids_to_remove$V1
df <- df[!(df$ID %in% id_list), ]

gene_cols <- c(
  "FEN1_vcf", "output_chr16_FTO_remove_ld", "LIG3_vcf", "LIG1_vcf",
  "TDG_vcf", "UNG_vcf", "MPG_vcf", "output_chr10_MGMT_remove_ld",
  "output_chr14_MLH3_remove_ld", "NTHL1_vcf", "XRCC1_vcf",
  "output_chr12_SMUG1_remove_ld", "MUTYH_vcf", "PARP1_vcf",
  "NEIL3_vcf", "NEIL2_vcf", "output_chr8_POLB_remove_ld", "MLH1_vcf", "OGG1_vcf"
)

df[gene_cols] <- lapply(df[gene_cols], function(x) as.numeric(as.character(x)))

# Example final BMI model.
model_bmi <- lm(
  BMI ~ Sex + Age + log(1 + MET) + Smoking + Qualif_Simplified +
    NEIL3_vcf + NEIL2_vcf + output_chr16_FTO_remove_ld + UNG_vcf +
    OGG1_vcf + TDG_vcf + MUTYH_vcf + NTHL1_vcf + FEN1_vcf +
    NEIL3_vcf:NEIL2_vcf + NTHL1_vcf:NEIL3_vcf + UNG_vcf:NEIL3_vcf +
    UNG_vcf:NEIL2_vcf + output_chr10_MGMT_remove_ld:NEIL2_vcf +
    TDG_vcf:PARP1_vcf,
  data = df
)

# Example final OCS model.
model_ocs <- lm(
  OCS ~ Sex + Age + log(1 + MET) + Smoking + Qualif_Simplified +
    NEIL2_vcf + NEIL3_vcf + output_chr16_FTO_remove_ld + TDG_vcf +
    MUTYH_vcf + NTHL1_vcf + UNG_vcf +
    NEIL3_vcf:NEIL2_vcf + NTHL1_vcf:NEIL3_vcf +
    output_chr10_MGMT_remove_ld:NEIL2_vcf + UNG_vcf:NEIL2_vcf +
    TDG_vcf:PARP1_vcf,
  data = df
)

modelsummary(
  list("BMI model" = model_bmi, "OCS model" = model_ocs),
  estimate = c("Estimate" = "{estimate}{stars}"),
  statistic = c("Std. Error" = "{std.error}", "p-value" = "{p.value}"),
  shape = term ~ model + statistic,
  output = "final_models_table.docx"
)

# Example robust-coefficient plot for the BMI model.
coef_df <- tidy(
  model_bmi,
  conf.int = TRUE,
  conf.level = 0.95,
  se = sqrt(diag(vcovHC(model_bmi, type = "HC3")))
) %>%
  filter(term != "(Intercept)") %>%
  mutate(
    term = factor(term, levels = rev(term)),
    sig = case_when(
      p.value < 0.001 ~ "***",
      p.value < 0.01  ~ "**",
      p.value < 0.05  ~ "*",
      p.value < 0.1   ~ ".",
      TRUE ~ " "
    )
  )

p <- ggplot(coef_df, aes(x = term, y = estimate)) +
  geom_point(size = 2.5) +
  geom_errorbar(
    aes(ymin = estimate - 1.96 * std.error, ymax = estimate + 1.96 * std.error),
    width = 0.2
  ) +
  coord_flip() +
  theme_bw(base_size = 12) +
  labs(title = "Regression coefficients", x = "Predictor", y = "Estimate (±95% CI)") +
  geom_text(aes(label = sig, y = estimate), hjust = -0.4)

print(summary(model_bmi))
print(summary(model_ocs))
print(p)
