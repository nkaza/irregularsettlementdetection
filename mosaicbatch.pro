PRO MOSAICBATCH
  COMPILE_OPT IDL2
  ; Start the application
  e = ENVI(/HEADLESS)

  ; Select input scenes
  files = FILE_SEARCH('D:\informalsettlements\banglore\MBI', '*.hdr')
  scenes = !NULL
  FOR i=0, N_ELEMENTS(files)-1 DO BEGIN
    raster = e.OpenRaster(files[i])
    scenes = [scenes, raster]
  ENDFOR
  ;;; does not work because it takes the value of the 'top raster'
  ; Create the mosaic raster
  mosaicRaster = ENVIMosaicRaster(scenes)

  ; Save it as ENVI format
  newFile = "D:\informalsettlements\banglore\mosaics\" + "mbi_mosaic"
  mosaicRaster.Export, newFile, 'ENVI'

  ; Close the ENVI session
  e.Close
END