# 02_visualise_hfp.R
# Visualise HFP-100 across the Steppe Eagle flyway.
# Reads local 1km flyway clips and produces a five-year panel figure.
# Date:      2026-04-29

require(terra)
require(sf)
require(tidyterra)
require(ggplot2)
require(rnaturalearth)
require(patchwork)

# display CRS
laea_crs <- "+proj=laea +lat_0=30 +lon_0=50 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"

# flyway bounding box (matches 01_download_hfp.R)
flyway_wgs84 <- st_bbox(c(xmin = 20, xmax = 80, ymin = -10, ymax = 55)) |>
  st_as_sfc() |>
  st_segmentize(1) |>
  st_set_crs(4326)

flyway_laea <- flyway_wgs84 |> st_transform(laea_crs)

# country outlines
world_shp <- ne_countries(scale = 50, returnclass = "sf") |>
  st_crop(flyway_wgs84) |>
  st_transform(laea_crs) |>
  st_crop(flyway_laea)

# output folder
fig_dir <- "figures/"
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)

# load all five years as a single multi-layer SpatRaster
years <- 2017:2021
files <- paste0("data/raw/threat_layers/hfp/hfp_", years, "_flyway_1km.tif")
hfp_stack <- rast(files)
names(hfp_stack) <- years
hfp_stack_laea <- project(hfp_stack, laea_crs, res = 1000) # reproject to LAEA (one call handles all layers)

# cookie cutter
flyway_bbox <- st_bbox(flyway_laea)
xlim <- c(flyway_bbox["xmin"] - 500000, flyway_bbox["xmax"] + 500000)
ylim <- c(flyway_bbox["ymin"] - 500000, flyway_bbox["ymax"] + 500000)

encl_rect <- list(cbind(
  c(xlim[1], xlim[2], xlim[2], xlim[1], xlim[1]),
  c(ylim[1], ylim[1], ylim[2], ylim[2], ylim[1])
)) |>
  st_polygon() |>
  st_sfc(crs = laea_crs)

cookie <- st_difference(encl_rect, flyway_laea)

# generate parallel labels (latitude lines) along a chosen longitude
# parallel labels with proper hemisphere handling
parallel_labels <- data.frame(lat = seq(-10, 50, by = 10), lon = 20) |>
  st_as_sf(coords = c("lon", "lat"), crs = 4326, remove = F) |>
  st_transform(laea_crs) |>
  dplyr::mutate(label = dplyr::case_when(
    lat == 0 ~ "0°",
    lat > 0  ~ paste0(lat, "°N"),
    lat < 0  ~ paste0(abs(lat), "°S")
  ))

# generate meridian labels (longitude lines) along the bottom edge
meridian_labels <- data.frame(lat = -10, lon = seq(20, 80, by = 20)) |> # bottom edge lon
  st_as_sf(coords = c("lon", "lat"), crs = 4326) |>
  st_transform(laea_crs) |>
  dplyr::mutate(label = paste0(seq(20, 80, by = 20), "°E"))

# plot per year
p_2017 <- ggplot() +
  theme_minimal(base_size = 8) +
  geom_spatraster(data = hfp_stack_laea[["2017"]]) +
  geom_sf(data = world_shp, fill = NA, colour = "grey30", linewidth = 0.15) +
  geom_sf(data = cookie, fill = "white", colour = NA) +
  geom_sf(data = flyway_laea, fill = NA, colour = "grey20", linewidth = 0.3) +
  coord_sf(xlim = xlim, ylim = ylim, expand = FALSE, crs = laea_crs, clip = "off") +
  scale_fill_viridis_c(option = "magma", direction = -1,
                       name = "Human Footprint",
                       limits = c(0, 50),
                       breaks = seq(0, 50, by = 10),
                       na.value = "transparent",
                       guide = guide_colourbar(
                         direction = "horizontal",
                         barwidth = 10,
                         barheight = 0.5,
                         title.position = "top",
                         title.hjust = 0.5)) +
  labs(title = "2017") +
  theme(axis.text = element_blank(),
        axis.title = element_blank(),
        plot.title = element_text(face = "bold", hjust = 0.5)) +
  geom_sf_text(data = parallel_labels, aes(label = label),
               size = 2.5, colour = "grey40",
               nudge_x = -250000, hjust = 1) +
  geom_sf_text(data = meridian_labels, aes(label = label),
               size = 2.5, colour = "grey40",
               nudge_y = -250000, vjust = 1)

p_2018 <- ggplot() +
  theme_minimal(base_size = 8) +
  geom_spatraster(data = hfp_stack_laea[["2018"]]) +
  geom_sf(data = world_shp, fill = NA, colour = "grey30", linewidth = 0.15) +
  geom_sf(data = cookie, fill = "white", colour = NA) +
  geom_sf(data = flyway_laea, fill = NA, colour = "grey20", linewidth = 0.3) +
  coord_sf(xlim = xlim, ylim = ylim, expand = FALSE, crs = laea_crs, clip = "off") +
  scale_fill_viridis_c(option = "magma", direction = -1,
                       name = "Human Footprint",
                       limits = c(0, 50),
                       breaks = seq(0, 50, by = 10),
                       na.value = "transparent",
                       guide = guide_colourbar(
                         direction = "horizontal",
                         barwidth = 10,
                         barheight = 0.5,
                         title.position = "top",
                         title.hjust = 0.5)) +
  labs(title = "2018") +
  theme(axis.text = element_blank(),
        axis.title = element_blank(),
        plot.title = element_text(face = "bold", hjust = 0.5)) +
  geom_sf_text(data = parallel_labels, aes(label = label),
               size = 2.5, colour = "grey40",
               nudge_x = -250000, hjust = 1) +
  geom_sf_text(data = meridian_labels, aes(label = label),
               size = 2.5, colour = "grey40",
               nudge_y = -250000, vjust = 1)

p_2019 <- ggplot() +
  theme_minimal(base_size = 8) +
  geom_spatraster(data = hfp_stack_laea[["2019"]]) +
  geom_sf(data = world_shp, fill = NA, colour = "grey30", linewidth = 0.15) +
  geom_sf(data = cookie, fill = "white", colour = NA) +
  geom_sf(data = flyway_laea, fill = NA, colour = "grey20", linewidth = 0.3) +
  coord_sf(xlim = xlim, ylim = ylim, expand = FALSE, crs = laea_crs, clip = "off") +
  scale_fill_viridis_c(option = "magma", direction = -1,
                       name = "Human Footprint",
                       limits = c(0, 50),
                       breaks = seq(0, 50, by = 10),
                       na.value = "transparent",
                       guide = guide_colourbar(
                         direction = "horizontal",
                         barwidth = 10,
                         barheight = 0.5,
                         title.position = "top",
                         title.hjust = 0.5)) +
  labs(title = "2019") +
  theme(axis.text = element_blank(),
        axis.title = element_blank(),
        plot.title = element_text(face = "bold", hjust = 0.5)) +
  geom_sf_text(data = parallel_labels, aes(label = label),
               size = 2.5, colour = "grey40",
               nudge_x = -250000, hjust = 1) +
  geom_sf_text(data = meridian_labels, aes(label = label),
               size = 2.5, colour = "grey40",
               nudge_y = -250000, vjust = 1)

p_2020 <- ggplot() +
  theme_minimal(base_size = 8) +
  geom_spatraster(data = hfp_stack_laea[["2020"]]) +
  geom_sf(data = world_shp, fill = NA, colour = "grey30", linewidth = 0.15) +
  geom_sf(data = cookie, fill = "white", colour = NA) +
  geom_sf(data = flyway_laea, fill = NA, colour = "grey20", linewidth = 0.3) +
  coord_sf(xlim = xlim, ylim = ylim, expand = FALSE, crs = laea_crs, clip = "off") +
  scale_fill_viridis_c(option = "magma", direction = -1,
                       name = "Human Footprint",
                       limits = c(0, 50),
                       breaks = seq(0, 50, by = 10),
                       na.value = "transparent",
                       guide = guide_colourbar(
                         direction = "horizontal",
                         barwidth = 10,
                         barheight = 0.5,
                         title.position = "top",
                         title.hjust = 0.5)) +
  labs(title = "2020") +
  theme(axis.text = element_blank(),
        axis.title = element_blank(),
        plot.title = element_text(face = "bold", hjust = 0.5)) +
  geom_sf_text(data = parallel_labels, aes(label = label),
               size = 2.5, colour = "grey40",
               nudge_x = -250000, hjust = 1) +
  geom_sf_text(data = meridian_labels, aes(label = label),
               size = 2.5, colour = "grey40",
               nudge_y = -250000, vjust = 1)

p_2021 <- ggplot() +
  theme_minimal(base_size = 8) +
  geom_spatraster(data = hfp_stack_laea[["2021"]]) +
  geom_sf(data = world_shp, fill = NA, colour = "grey30", linewidth = 0.15) +
  geom_sf(data = cookie, fill = "white", colour = NA) +
  geom_sf(data = flyway_laea, fill = NA, colour = "grey20", linewidth = 0.3) +
  coord_sf(xlim = xlim, ylim = ylim, expand = FALSE, crs = laea_crs, clip = "off") +
  scale_fill_viridis_c(option = "magma", direction = -1,
                       name = "Human Footprint",
                       limits = c(0, 50),
                       breaks = seq(0, 50, by = 10),
                       na.value = "transparent",
                       guide = guide_colourbar(
                         direction = "horizontal",
                         barwidth = 10,
                         barheight = 0.5,
                         title.position = "top",
                         title.hjust = 0.5)) +
  labs(title = "2021") +
  theme(axis.text = element_blank(),
        axis.title = element_blank(),
        plot.title = element_text(face = "bold", hjust = 0.5)) +
  geom_sf_text(data = parallel_labels, aes(label = label),
               size = 2.5, colour = "grey40",
               nudge_x = -250000, hjust = 1) +
  geom_sf_text(data = meridian_labels, aes(label = label),
               size = 2.5, colour = "grey40",
               nudge_y = -250000, vjust = 1)


p <- p_2017 + p_2018 + p_2019 + p_2020 + p_2021 + guide_area() + 
  plot_layout(ncol = 3, guides = "collect") + 
  plot_annotation(
    title = "Human Footprint across the Steppe Eagle flyway, 2017–2021",
    subtitle = "HFP-100 v1.2 (Mazzariello & Gassert 2023)")

ggsave(filename = "hfp_flyway_panel_2017-2021.jpg",
       path = "figures/",
       plot = p,
       width = 180,
       height = 140,
       units = "mm",
       dpi = 300)
