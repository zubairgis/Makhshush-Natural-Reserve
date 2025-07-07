pkgs <- c("sf", "nnet", "caret", "dplyr", "ggplot2")
new  <- pkgs[!pkgs %in% installed.packages()[, "Package"]]
if (length(new)) install.packages(new, dependencies = TRUE)

library(sf)
library(nnet)
library(caret)
library(dplyr)
library(ggplot2)

shp_path <- "D:/1 Research_Papers/1 Asir_Et/Variables/Data_XGB_Predicted.shp"
data_sf  <- st_read(shp_path)
df       <- as.data.frame(data_sf)

df$Plant_S <- as.numeric(df$Plant_S)
predictors <- c("NDVI_SS", "NDWI_SS", "LST_SS", "Veg_Type", "PAW", "Ph", "OCC")

valid_rows <- complete.cases(df[, c(predictors, "Plant_S")])
df       <- df[valid_rows, ]
data_sf  <- data_sf[valid_rows, ]

df_scaled <- df
df_scaled[, predictors] <- scale(df[, predictors])

set.seed(42)
train_idx <- sample(seq_len(nrow(df_scaled)), 10000)
train <- df_scaled[train_idx, ]
test  <- df_scaled[-train_idx, ]

set.seed(42)
ann_model <- nnet(
  Plant_S ~ ., 
  data = train[, c(predictors, "Plant_S")],
  size = 10,
  linout = TRUE,
  maxit = 500,
  trace = FALSE
)

all_scaled <- df_scaled[, predictors]
pred_ann <- predict(ann_model, newdata = all_scaled)

data_sf$Pred_ANN <- pred_ann

compare_df <- data.frame(True = df$Plant_S)
if ("Pred_RF" %in% names(df))  compare_df$RF  <- df$Pred_RF
if ("Pred_XGB" %in% names(df)) compare_df$XGB <- df$Pred_XGB
compare_df$ANN <- pred_ann

cat("✅ Model Performance Summary (Full Data):\n")
if ("RF" %in% names(compare_df)) {
  rmse_rf <- sqrt(mean((compare_df$RF - compare_df$True)^2))
  r2_rf   <- cor(compare_df$RF, compare_df$True)^2
  cat("Random Forest → RMSE:", round(rmse_rf, 3), "| R²:", round(r2_rf, 3), "\n")
}
if ("XGB" %in% names(compare_df)) {
  rmse_xgb <- sqrt(mean((compare_df$XGB - compare_df$True)^2))
  r2_xgb   <- cor(compare_df$XGB, compare_df$True)^2
  cat("XGBoost       → RMSE:", round(rmse_xgb, 3), "| R²:", round(r2_xgb, 3), "\n")
}
rmse_ann <- sqrt(mean((compare_df$ANN - compare_df$True)^2))
r2_ann   <- cor(compare_df$ANN, compare_df$True)^2
cat("ANN           → RMSE:", round(rmse_ann, 3), "| R²:", round(r2_ann, 3), "\n")

ggplot(compare_df, aes(x = True, y = ANN)) +
  geom_point(alpha = 0.3) +
  geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +
  labs(title = "ANN Predicted vs Actual Suitability",
       x = "Observed Plant_S", y = "Pred_ANN") +
  theme_minimal()

out_path <- "D:/1 Research_Papers/1 Asir_Et/Variables/Data_ANN_Predicted.shp"
st_write(data_sf, out_path, delete_layer = TRUE)

cat("\n✅ ANN prediction added and saved to:\n", out_path, "\n")
