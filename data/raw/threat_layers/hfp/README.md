# Human Footprint Index (HFP-100 v1.2)

*Annual human pressure layers, clipped to the Steppe Eagle flyway, aggregated to 1km.*
  
  ---
  
## Source
  
HFP-100 v1.2, hosted on Source Cooperative:
https://source.coop/vizzuality/hfp-100

The dataset is an updated, 100m-resolution implementation of the Human Footprint
framework introduced by Venter et al. (2016) and extended by Williams et al. (2020).

## Citation

Mazzariello, J. & Gassert, F. (2023). *Human Footprint Map at 100m resolution,
v1.2*. Vizzuality / Source Cooperative.

Williams, B.A., Venter, O., Allan, J.R., Atkinson, S.C., Rehbein, J.A.,
Ward, M., Di Marco, M., Grantham, H.S., Ervin, J., Goetz, S.J., et al. (2020).
Change in terrestrial human footprint drives continued loss of intact ecosystems.
*One Earth* 3, 371–382. doi:10.1016/j.oneear.2020.08.009

Venter, O., Sanderson, E.W., Magrach, A., Allan, J.R., Beher, J., Jones, K.R.,
Possingham, H.P., Laurance, W.F., Wood, P., Fekete, B.M., Levy, M.A., &
  Watson, J.E.M. (2016). Sixteen years of change in the global terrestrial human
footprint and implications for biodiversity conservation. *Nature Communications*
  7, 12558. doi:10.1038/ncomms12558

## Files in this folder

| File | Description |
  |------|-------------|
  | `hfp_2017_flyway_1km.tif` | HFP for 2017, flyway clip, 1km |
  | `hfp_2018_flyway_1km.tif` | HFP for 2018, flyway clip, 1km |
  | `hfp_2019_flyway_1km.tif` | HFP for 2019, flyway clip, 1km |
  | `hfp_2020_flyway_1km.tif` | HFP for 2020, flyway clip, 1km |
  | `hfp_2021_flyway_1km.tif` | HFP for 2021, flyway clip, 1km |
  
  ## Processing
  
  Files are not stored in version control. To regenerate, run:
  
  ```r
source("01_download_hfp.R")
```

The script:
1. Streams the global 100m HFP COG from Source Cooperative via `/vsicurl/`
2. Crops to the Steppe Eagle flyway bounding box (20–80°E, -10–55°N, WGS84)
3. Masks the 65535 NoData sentinel
4. Rescales from uint16 (×1000) back to the native 0–50 HFP range
5. Aggregates from 100m to 1km (mean)
6. Writes compressed GeoTIFF in source CRS (Mollweide)

See also `R/download_hfp_year.R` for the per-year processing function.

## CRS, units, value range

- **CRS:** Mollweide (`+proj=moll +lon_0=0 +datum=WGS84 +units=m`)
- **Resolution:** ~1 km
- **Values:** 0–50 (continuous), where 0 = no measurable human pressure and
50 = maximum pressure
- **NoData:** `NA` (already reclassified from the 65535 source sentinel)

## Notes and caveats

- HFP-100 does **not** include powerlines or wind energy infrastructure as
inputs — these need separate threat layers. HFP serves as a baseline
cumulative pressure surface, not a replacement for eagle-specific
infrastructure layers.
- Some extreme deserts (e.g. parts of the Empty Quarter) are NoData rather
than scored as low pressure. These should be treated as data-limited
rather than pressure-free in any exposure calculations.
- Files are aggregated to 1km for visualisation and exploratory analysis.
For final exposure analyses consider whether 100m source resolution is needed
and re-clip from the remote source if so.

---
  
  *Last updated: April 2026*