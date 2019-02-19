library(raster)
library(SDMTools)

# SDMTools is not maintained anymore. Please switch over to landscapemetrics https://github.com/r-spatialecology/landscapemetrics

# initialise rasters
r <- raster("D:\\informalsettlements\\banglore\\mosaics\\mbi_mosaic.tif")
r <- r>20 # Create a building object raster by thresholding the rasters


# Different functions for landscape metrics.

localLmetrics.npatches<- function(y, wsize=50,...){
  if(sum(y, na.rm=T) >0){
  r2 <- matrix(y>0, nrow=wsize)
  ClassStat(r2, bkgd=0, cellsize = 2)$n.patches
  } else NA
}

localLmetrics.meanarea<- function(y, wsize=50,...){
  if(sum(y, na.rm=T) >0){
    r2 <- matrix(y>0, nrow=wsize)
    ClassStat(r2, bkgd=0, cellsize = 2)$mean.patch.area
  } else NA
}

localLmetrics.sdarea<- function(y, wsize=50,...){
  if(sum(y, na.rm=T) >0){
    r2 <- matrix(y>0, nrow=wsize)
    ClassStat(r2, bkgd=0, cellsize = 2)$sd.patch.area
  } else NA
}

localLmetrics.maxarea<- function(y, wsize=50,...){
  if(sum(y, na.rm=T) >0){
    r2 <- matrix(y>0, nrow=wsize)
    ClassStat(r2, bkgd=0, cellsize = 2)$max.patch.area
  } else NA
}

# Different aggregation functions for 1 ha rasters

aggregate(r, fact=50, fun=localLmetrics.npatches, filename='D:\\informalsettlements\\banglore\\mosaics\\numberbuildings.tif', overwrite=T)
aggregate(r, fact=50, fun=localLmetrics.meanarea, filename='D:\\informalsettlements\\banglore\\mosaics\\meanbuildingsize.tif', overwrite=T)
aggregate(r, fact=50, fun=localLmetrics.sdarea, filename='D:\\informalsettlements\\banglore\\mosaics\\sdbuildingsize.tif', overwrite=T)
aggregate(r, fact=50, fun=localLmetrics.maxarea, filename='D:\\informalsettlements\\banglore\\mosaics\\maxbuildingsize.tif', overwrite=T)





