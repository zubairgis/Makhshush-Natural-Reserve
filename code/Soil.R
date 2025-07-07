library(terra)

setwd("D:/1 Research_Papers/1 Asir_Et/Soil")

weights <- c(5, 10, 15, 30, 40)

fc_files <- c("FC_33hp_5.tif", "FC_33hp_15.tif", "FC_33hp_30.tif", 
              "FC_33hp_60.tif", "FC_33hp_100.tif")
fc_stack <- rast(fc_files)
fc_weighted <- sum(fc_stack * weights) / sum(weights)

pwp_files <- c("PWP_1500hp_5.tif", "PWP_1500hp_15.tif", "PWP_1500hp_30.tif", 
               "PWP_1500hp_60.tif", "PWP_1500hp_100.tif")
pwp_stack <- rast(pwp_files)
pwp_weighted <- sum(pwp_stack * weights) / sum(weights)

paw_weighted <- fc_weighted - pwp_weighted

ph_files <- c("phh2o_5.tif", "phh2o_15.tif", "phh2o_30.tif", 
              "phh2o_60.tif", "phh2o_100.tif")
ph_stack <- rast(ph_files)
ph_weighted <- sum(ph_stack * weights) / sum(weights)

ocd_files <- c("ocd_5.tif", "ocd_15.tif", "ocd_30.tif", 
               "ocd_60.tif", "ocd_100.tif")
ocd_stack <- rast(ocd_files)
ocd_weighted <- sum(ocd_stack * weights) / sum(weights)

cec_files <- c("cec_5.tif", "cec_15.tif", "cec_30.tif", 
               "cec_60.tif", "cec_100.tif")
cec_stack <- rast(cec_files)
cec_weighted <- sum(cec_stack * weights) / sum(weights)

writeRaster(fc_weighted,   "FC_weighted_0_100.tif",  overwrite = TRUE)
writeRaster(pwp_weighted,  "PWP_weighted_0_100.tif", overwrite = TRUE)
writeRaster(paw_weighted,  "PAW_weighted_0_100.tif", overwrite = TRUE)
writeRaster(ph_weighted,   "pH_weighted_0_100.tif",  overwrite = TRUE)
writeRaster(ocd_weighted,  "OC_weighted_0_100.tif",  overwrite = TRUE)
writeRaster(cec_weighted,  "CEC_weighted_0_100.tif", overwrite = TRUE)
