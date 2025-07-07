library(terra)

setwd("D:/1 Research_Papers/1 Asir_Et/Variables")

rescale <- function(x) {
  r_min <- global(x, "min", na.rm = TRUE)[[1]]
  r_max <- global(x, "max", na.rm = TRUE)[[1]]
  (x - r_min) / (r_max - r_min)
}

ndvi_slope <- rast("NDVI_Slope.tif")
ndwi_slope <- rast("NDWI_Slope.tif")
lst_slope  <- rast("LST_Slope.tif")
veg_type   <- rast("Veg_Type.tif")
paw        <- rast("PAW.tif")
ph         <- rast("Ph.tif")
occ        <- rast("OCC.tif")

ref <- ndvi_slope

ndwi_slope <- resample(ndwi_slope, ref)
lst_slope  <- resample(lst_slope, ref)
veg_type   <- resample(veg_type, ref, method = "near")
paw        <- resample(paw, ref)
ph         <- resample(ph, ref)
occ        <- resample(occ, ref)

ndvi_score <- rescale(-ndvi_slope)
ndwi_score <- rescale(ndwi_slope)
lst_score  <- rescale(-lst_slope)

veg_score <- classify(veg_type, rcl = matrix(c(
  1, 1.0,
  2, 0.7,
  3, 0.4
), ncol = 2, byrow = TRUE))

paw_score <- rescale(paw)

ph_score <- classify(ph, rcl = matrix(c(
  -Inf, 6.5, 0.4,
   6.5, 8.5, 1.0,
   8.5, Inf, 0.4
), ncol = 3, byrow = TRUE))

oc_score <- rescale(occ)

suitability_index <- (
  ndvi_score * 0.25 +
  ndwi_score * 0.15 +
  lst_score  * 0.10 +
  veg_score  * 0.15 +
  paw_score  * 0.15 +
  ph_score   * 0.05 +
  oc_score   * 0.10
)

writeRaster(suitability_index, "Suitability_Index_0_1.tif", overwrite = TRUE)
