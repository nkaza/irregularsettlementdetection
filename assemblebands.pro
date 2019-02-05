PRO assemblebands
  COMPILE_OPT IDL2
  ; Start the application
  e = ENVI(/headless)
  
  

  maskfile = e.openRaster("D:\informalsettlements\banglore\mosaics\mask_mosaic_al.tif")
  mbifile = e.OpenRaster("D:\informalsettlements\banglore\mosaics\mbi_mosaic.tif")
  haralick3file = e.openRaster("D:\informalsettlements\banglore\mosaics\haralick3_mosaic.tif")
  haralick5file = e.openRaster("D:\informalsettlements\banglore\mosaics\haralick5_mosaic.tif")
  cannyneigh5file = e.openraster("D:\informalsettlements\banglore\mosaics\canny_mosaic_conv5")
  

  
  ; Get the spatial reference of the thermal band raster

  ; since it has the coarsest spatial resolution (60 m)

  spatialRef = mbifile.SPATIALREF
  nCols = mbifile.NCOLUMNS
  nRows = mbifile.NROWS
  coordSysCode = spatialRef.COORD_SYS_CODE
  coordSys = ENVICoordSys(COORD_SYS_CODE=coordSysCode)
  pixelSize = spatialRef.PIXEL_SIZE
  tiePointMap = spatialRef.TIE_POINT_MAP
  tiePointPixel = spatialRef.TIE_POINT_PIXEL
  
  Grid = ENVIGridDefinition(coordSys, $
    PIXEL_SIZE=pixelSize, $
    TIE_POINT_MAP=tiePointMap, $
    TIE_POINT_PIXEL=tiePointPixel, $
    NCOLUMNS=nCols, $
    NROWS=nRows)
    
    
  
  layerStack = ENVILayerStackRaster([mbifile, haralick5file, cannyneigh5file], GRID_DEFINITION=Grid)
 ; layerStackWithMask = ENVIMaskRaster(layerStack, maskfile)
  layerStack.Export, "D:\informalsettlements\banglore\mosaics\allbands.tiff", "tiff"
  
  
  envi_doit, 'cf_doit', DIMS=rgbmax_dims, FID=fidarray, POS= FLTARR(fidarray.LENGTH), out_name='dmp_cf', R_FID=dmp_fid, /INVISIBLE
  ENVI_File_Query, dmp_fid, DIMS=dims, NB=nb
  
  envi_doit, 'envi_mask_apply_doit', FID=radfile_fid, DIMS=radfile_dims, POS=Lindgen(radfile_nb), $
    VALUE=0, M_FID=ENVIRasterToFID(maskraster), M_POS=[0], $
    OUT_BNAME='Masked ('+radfile_bnames+')', $
    R_FID=masked01_fid, OUT_NAME='C:\scratch\blore\' + strcompress(File_basename(file, ".tif") + "_urbmasked"), /INVISIBLE