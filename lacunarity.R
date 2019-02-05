library(raster)

r <- raster("D:\\informalsettlements\\banglore\\mosaics\\mbi_mosaic.tif")
r <- r>20

lac.bin2 <- function(y, wsize=50, glideboxsize=10, ...){
  r2 <- raster(matrix(y>0, nrow=wsize))
  r3 <- aggregate(r2, fact=glideboxsize, sum)
  cellStats(r3, var)/(cellStats(r3, mean))^2
}

aggregate(r, fact=50, fun=lac.bin2, filename='D:\\informalsettlements\\banglore\\mosaics\\lac_agg.tif', overwrite=T)


