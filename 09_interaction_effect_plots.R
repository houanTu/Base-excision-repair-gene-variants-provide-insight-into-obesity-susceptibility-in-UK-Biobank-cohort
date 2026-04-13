############################################################
## Example R code for visualizing selected interaction effects
## from the final multivariable models
############################################################

library(visreg)
library(sandwich)
library(effects)

df <- readRDS("/home/rstudio-server/merged_data.rds")
df$Birth <- as.numeric(df$Birth)

ids_to_remove <- read.csv("/mnt/project/w71219_20250818.csv", header = FALSE)
id_list <- ids_to_remove$V1
df <- df[!(df$ID %in% id_list), ]

model <- lm(
  OCS ~ Sex + Age + log(1 + MET) + Smoking + Qualif_Simplified +
    NEIL2_vcf + NEIL3_vcf + output_chr16_FTO_remove_ld + TDG_vcf +
    MUTYH_vcf + NTHL1_vcf + UNG_vcf +
    NEIL3_vcf:NEIL2_vcf + NTHL1_vcf:NEIL3_vcf +
    output_chr10_MGMT_remove_ld:NEIL2_vcf + UNG_vcf:NEIL2_vcf +
    TDG_vcf:PARP1_vcf,
  data = df
)

out_dir <- "/home/rstudio-server/effect_plots_interaction"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# Example interaction: NEIL2 × UNG.
png(file.path(out_dir, "NEIL2_UNG_3D.png"), width = 2000, height = 1600, res = 200)
visreg2d(
  model,
  xvar = "NEIL2_vcf",
  yvar = "UNG_vcf",
  plot.type = "persp",
  xlab = "NEIL2_vcf",
  ylab = "UNG_vcf",
  zlab = "Predicted contribution to OCS",
  main = "",
  theta = 40,
  phi = 25
)
dev.off()

png(file.path(out_dir, "NEIL2_UNG_heatmap.png"), width = 2000, height = 1600, res = 200)
visreg2d(
  model,
  xvar = "NEIL2_vcf",
  yvar = "UNG_vcf",
  plot.type = "image",
  xlab = "NEIL2_vcf",
  ylab = "UNG_vcf",
  main = "Linear predictor"
)
dev.off()

# Optional allEffects plot with robust covariance.
png(file.path(out_dir, "all_effects.png"), width = 2200, height = 1800, res = 180)
ef <- allEffects(model, vcov. = function(mod, ...) vcovHC(mod, type = "HC3"))
plot(ef)
dev.off()
