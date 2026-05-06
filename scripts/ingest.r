# ---
# Script:  01_ingest.R
# Purpose: Pull Steppe Eagle telemetry from Movebank and cache locally.
#          Download only — no QC or processing.
# ---
#
# Prerequisites (one-time, run interactively in the console):
#   install.packages(c("move2", "keyring", "here"))
#   move2::movebank_store_credentials("your_username", "your_password")
#
# Each study also requires a one-off licence acceptance via the Movebank
# website before the API will release data.

library(tidyverse)
library(move2)
library(here)

# Long timeout — Movebank pulls can be slow
options(timeout = 600)

# --- Discover studies ---------------------------------------------------------

all_studies <- movebank_download_study_info()

steppe_studies <- all_studies |>
  filter(map_lgl(taxon_ids,
                 ~ isTRUE(any(grepl("Aquila nipalensis", .x, ignore.case = TRUE)))))

downloadable <- steppe_studies |>
  filter(i_have_download_access == TRUE)

# --- Pull ---------------------------------------------------------------------

cache_dir <- here("data", "raw", "tracking")
dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)

study_1 <- movebank_download_study(
  downloadable$id[1],
  sensor_type_id = "gps",
  attributes     = NULL
)
saveRDS(study_1, file.path(cache_dir, "efrat_steppe_eagles.rds"))

study_2 <- movebank_download_study(
  downloadable$id[2],
  sensor_type_id = "gps",
  attributes     = NULL
)
saveRDS(study_2, file.path(cache_dir, "acbk_steppe_eagles.rds"))
