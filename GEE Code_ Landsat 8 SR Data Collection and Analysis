var aoi       = ee.FeatureCollection('projects/zubair-1300/assets/Makhshush');
var startYear = 2014;
var endYear   = 2024;
var maxCloud  = 30;
var L8SR      = 'LANDSAT/LC08/C02/T1_L2';
var outScale  = 30;

var SCALE  = 0.0000275;
var OFFSET = -0.2;

var years    = ee.List.sequence(startYear, endYear).getInfo();
var yearImgs = [];

years.forEach(function (yr) {
  var ndvi = ee.ImageCollection(L8SR)
      .filterBounds(aoi)
      .filterDate(ee.Date.fromYMD(yr, 1, 1), ee.Date.fromYMD(yr, 12, 31))
      .filter(ee.Filter.lt('CLOUD_COVER', maxCloud))
      .map(function (img) {
        var sr = img.select(['SR_B4', 'SR_B5']).multiply(SCALE).add(OFFSET);
        return sr.normalizedDifference(['SR_B5', 'SR_B4']).rename('NDVI');
      })
      .median()
      .rename('NDVI_' + yr);
  yearImgs.push(ndvi);
});

var ndviStack = ee.ImageCollection.fromImages(yearImgs).toBands().clip(aoi);

var ndviMean       = ndviStack.reduce(ee.Reducer.mean()).rename('NDVI_Mean');
var ndviSD         = ndviStack.reduce(ee.Reducer.stdDev()).rename('NDVI_SD');
var ndviMeanMasked = ndviMean.updateMask(ndviMean.gt(0.05));
var ndviCV         = ndviSD.divide(ndviMeanMasked).rename('NDVI_CV');

var pcts = ndviMeanMasked.addBands(ndviCV).reduceRegion({
  reducer  : ee.Reducer.percentile([25, 75]),
  geometry : aoi,
  scale    : outScale,
  maxPixels: 1e9
});

var mean25 = ee.Number(pcts.get('NDVI_Mean_p25'));
var mean75 = ee.Number(pcts.get('NDVI_Mean_p75'));
var cv25   = ee.Number(pcts.get('NDVI_CV_p25'));
var cv75   = ee.Number(pcts.get('NDVI_CV_p75'));

var vegClass = ee.Image(0)
  .where(ndviMeanMasked.gte(mean75).and(ndviCV.lte(cv25)), 1)
  .where(ndviMeanMasked.gt(mean25) .and(ndviMeanMasked.lt(mean75))
         .and(ndviCV.gt(cv25)).and(ndviCV.lt(cv75)), 2)
  .where(ndviMeanMasked.lte(mean25).and(ndviCV.gte(cv75)), 3)
  .updateMask(ee.Image(1));

Map.centerObject(aoi, 10);
Map.addLayer(ndviMeanMasked, {min: 0, max: 0.5, palette: ['white', 'green']}, 'NDVI Mean 2014–2024');
Map.addLayer(ndviCV,         {min: 0, max: 1  , palette: ['white', 'red']  }, 'NDVI CV 2014–2024');
Map.addLayer(vegClass,       {min: 1, max: 3  , palette: ['006400', 'FFD700', 'D2691E']}, 'NDVI Classes');

Export.image.toDrive({
  image      : vegClass,
  description: 'NDVI_Temporal_Class_2014_2024',
  region     : aoi.geometry(),
  scale      : outScale,
  fileFormat : 'GeoTIFF',
  maxPixels  : 1e13
});

[
  {img: ndviMeanMasked, desc: 'NDVI_Mean_2014_2024'},
  {img: ndviCV,         desc: 'NDVI_CV_2014_2024'}
].forEach(function (o) {
  Export.image.toDrive({
    image      : o.img,
    description: o.desc,
    region     : aoi.geometry(),
    scale      : outScale,
    fileFormat : 'GeoTIFF',
    maxPixels  : 1e13
  });
});
