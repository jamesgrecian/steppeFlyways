# 01_download_hfp.R
# Download HFP-100 v1.2 annual layers (2017–2021), clip to Steppe Eagle flyway,
# aggregate to 1km, save in source (Mollweide) CRS.
#
# Run once. Skips files that already exist on subsequent runs.
#
# Source:    https://source.coop/vizzuality/hfp-100
# Citation:  Mazzariello & Gassert 2023; Williams et al. 2020 One Earth.
# Date:      2026-04-29

library(terra)
library(sf)
source("R/download_hfp_year.r")

# Flyway bounding box in WGS84
flyway_wgs84 <- st_bbox(c(xmin = 20, xmax = 80, ymin = -10, ymax = 60)) |>
  st_as_sfc() |>
  st_segmentize(1) |>             # ~1° vertex spacing preserves shape on reprojection
  st_set_crs(4326)

# Source CRS for HFP-100 is Mollweide; project the bbox to match
moll_crs    <- "+proj=moll +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"
flyway_moll <- flyway_wgs84 |> st_transform(moll_crs) |> vect()

# output folder
out_dir <- "data/raw/threat_layers/hfp"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# process each year individually
# the raw data is 20GB so clear cache between processing steps
download_hfp_year(2017, flyway_moll, out_dir)
tmpFiles(remove = TRUE)

download_hfp_year(2018, flyway_moll, out_dir)
tmpFiles(remove = TRUE)

download_hfp_year(2019, flyway_moll, out_dir)
tmpFiles(remove = TRUE)

download_hfp_year(2020, flyway_moll, out_dir)
tmpFiles(remove = TRUE)

download_hfp_year(2021, flyway_moll, out_dir)
tmpFiles(remove = TRUE)

# ends
