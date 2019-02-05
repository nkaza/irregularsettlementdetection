library(raster)
library(tools)

wd <- "D:\\informalsettlements\\banglore\\haralick3"
setwd(wd)

filelist <- list.files(pattern="\\.tif$")
#filelist <- file_path_sans_ext(filelist)

rastlist <- lapply(filelist, brick)
rastlist$fun <- max
rastlist$na.rm <- TRUE
rastlist$filename <- "D:\\informalsettlements\\banglore\\mosaics\\haralick3_mosaic.tif"


do.call(mosaic, rastlist)

