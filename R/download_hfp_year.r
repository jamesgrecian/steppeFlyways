# Download a single year of HFP-100 v1.2, clip to a bounding box,
# aggregate to 1km, save in source (Mollweide) CRS.
#
# Inputs:
#   year       — integer, e.g. 2020
#   bbox_moll  — SpatVector polygon in Mollweide CRS, defining the clip extent
#   out_dir    — character, output folder
#
# Output:
#   path to the saved .tif (invisibly); skips if the file already exists.

download_hfp_year <- function(year, bbox_moll, out_dir) {
  
  out_file <- file.path(out_dir, paste0("hfp_", year, "_flyway_1km.tif"))
  
  if (file.exists(out_file)) {
    message("  ", year, ": exists, skipping")
    return(invisible(out_file))
  }
  
  message("  ", year, ": downloading and processing...")
  
  url <- paste0("/vsicurl/https://data.source.coop/vizzuality/hfp-100/hfp_",
                year, "_100m_v1-2_cog.tif")
  
  hfp <- rast(url)
  hfp_clip <- crop(hfp, bbox_moll, mask = TRUE)
  hfp_clip <- classify(hfp_clip, cbind(65535, NA))
  hfp_clip <- hfp_clip / 1000
  hfp_1km <- aggregate(hfp_clip, fact = 10, fun = "mean", na.rm = TRUE)
  
  writeRaster(hfp_1km, out_file, overwrite = TRUE,
              gdal = c("COMPRESS=DEFLATE", "PREDICTOR=2", "TILED=YES"))
  
  # clear terra temp files to free disk between years
  tmpFiles(remove = TRUE)
  
  invisible(out_file)
}

# ends
