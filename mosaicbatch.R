library(raster)
library(tools)

wd <- "D:\\informalsettlements\\banglore\\haralick3"
setwd(wd)

filelist <- list.files(pattern="\\.tif$")
#filelist <- file_path_sans_ext(filelist)

### Bricking a set of rasters. We use the max function, when there is a overlap of pixels

rastlist <- lapply(filelist, brick)
rastlist$fun <- max
rastlist$na.rm <- TRUE
rastlist$filename <- "D:\\informalsettlements\\banglore\\mosaics\\haralick3_mosaic.tif"

## Use do.call to mosaic a list of rasters. 
do.call(mosaic, rastlist)

