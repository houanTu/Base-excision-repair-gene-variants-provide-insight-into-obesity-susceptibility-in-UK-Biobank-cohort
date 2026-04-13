############################################################
## Example R code for RAP / DNAnexus and PLINK2 setup
## for BER-related genetic analyses in UK Biobank
##
## This script defines helper functions used by downstream
## example workflows in this repository.
############################################################

setup_plink2 <- function(
  work_dir = "/home/rstudio-server",
  plink_zip = "plink2_linux_avx2_20250414.zip",
  plink_url = "https://s3.amazonaws.com/plink2-assets/alpha6/plink2_linux_avx2_20250414.zip"
) {
  setwd(work_dir)

  if (!file.exists(file.path(work_dir, "plink2"))) {
    download.file(plink_url, destfile = plink_zip, mode = "wb")
    unzip(plink_zip)
    Sys.chmod("plink2", mode = "0755")
  }

  plink2_path <- if (file.exists(file.path(work_dir, "plink2"))) {
    file.path(work_dir, "plink2")
  } else {
    Sys.which("plink2")
  }

  if (!nzchar(plink2_path)) {
    stop("PLINK2 was not found in the working directory or PATH.")
  }

  plink2_path
}

choose_output_dir <- function(
  preferred = "/home/rstudio-server/output",
  fallback = "/tmp/output"
) {
  out_dir <- if (file_test("-w", dirname(preferred))) preferred else fallback

  if (!dir.exists(out_dir)) {
    dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  }

  if (!file_test("-w", out_dir)) {
    stop("No writable output directory is available.")
  }

  out_dir
}

upload_to_rap <- function(files, destination = "/") {
  files <- normalizePath(files, mustWork = TRUE)
  cmd <- paste(
    "dx upload",
    paste(shQuote(files), collapse = " "),
    "--destination",
    shQuote(destination)
  )
  system(cmd)
}
