library(raster)
library(SDMTools)

r <- raster("D:\\informalsettlements\\banglore\\mosaics\\mbi_mosaic.tif")
#r <- raster('/Users/nikhilkaza/Dropbox/India_GISdata/blore/test_mbi.tif')

r <- r>20


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

aggregate(r, fact=50, fun=localLmetrics.npatches, filename='D:\\informalsettlements\\banglore\\mosaics\\numberbuildings.tif', overwrite=T)
aggregate(r, fact=50, fun=localLmetrics.meanarea, filename='D:\\informalsettlements\\banglore\\mosaics\\meanbuildingsize.tif', overwrite=T)
aggregate(r, fact=50, fun=localLmetrics.sdarea, filename='D:\\informalsettlements\\banglore\\mosaics\\sdbuildingsize.tif', overwrite=T)
aggregate(r, fact=50, fun=localLmetrics.maxarea, filename='D:\\informalsettlements\\banglore\\mosaics\\maxbuildingsize.tif', overwrite=T)





