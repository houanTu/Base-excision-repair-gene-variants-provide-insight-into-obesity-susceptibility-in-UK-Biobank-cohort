# Example code for BER-related genetic analyses in UK Biobank

This repository contains example R code for the main genotype-processing and association-analysis steps used in the UK Biobank component of the BER–obesity project.

The shared code is intended for manuscript supplement / GitHub sharing. It is a cleaned, example-style version of the analytical workflow rather than a full archive of every interactive command used during the project.

## Repository purpose

The scripts illustrate how the following steps were performed:

1. prepare the RAP / DNAnexus working environment and PLINK2
2. apply basic genotype QC and extract gene-level datasets
3. run LD analysis and summarize LD outputs
4. compute per-gene allele-burden scores from VCF files
5. prepare simplified VCF files for downstream annotation
6. merge phenotype and genotype data and derive the obesogenic composite score (OCS)
7. run single-gene screening models
8. fit final multivariable models with selected main effects and interaction terms
9. visualize selected interaction effects

## Repository structure

```text
.
├── README.md
├── .gitignore
├── results_placeholder/
└── scripts/
    ├── 00_setup_plink_dx.R
    ├── 01_qc_extract_gene_and_export_vcf.R
    ├── 02_run_ld_analysis.R
    ├── 03_summarize_ld_vcor.R
    ├── 04_compute_gene_risk_scores.R
    ├── 05_prepare_annotation_vcf.R
    ├── 06_merge_and_prepare_analysis_data.R
    ├── 07_single_gene_models.R
    ├── 08_final_multivariable_models.R
    └── 09_interaction_effect_plots.R
```

## Notes for reuse

- Paths such as `/mnt/project` and `/home/rstudio-server` assume a UK Biobank RAP / DNAnexus environment and should be adapted if the code is run elsewhere.
- UK Biobank raw data are not included and cannot be redistributed through this repository.
- Project-specific inputs must be provided by the user, such as phenotype files, gene range files, exclusion lists, and annotated VCF files.
- The scripts are written as example workflows. Some variables, file names, and model terms should be adapted to match the final analytical specification used in a given manuscript.

## Main software requirements

### R packages

- `dplyr`
- `tidyr`
- `stringr`
- `readr`
- `data.table`
- `car`
- `psych`
- `modelsummary`
- `broom`
- `sandwich`
- `lmtest`
- `effects`
- `visreg`
- `R.utils`

### External tools

- `plink2`
- `dx` CLI
- standard shell utilities such as `awk` and `cut`

## Suggested manuscript wording

### Code availability

> Example analysis scripts used for UK Biobank genotype processing, gene-level score construction, regression modelling, and visualization are available in a public GitHub repository upon publication.

### Data availability

> The UK Biobank data used in this study are available through application to the UK Biobank resource and cannot be publicly shared by the authors.
