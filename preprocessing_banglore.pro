PRO preprocessing_banglore
  COMPILE_OPT IDL2
  ; Start the application
  e = ENVI(/Headless)


mul_imgfile = e.openraster("D:\Google Drive\Bangalore Project\Georeferenced Mosaics\MUL_mosaic_415.tif")
Gains = [0.196525454545,0.328465561694,0.216539206349,0.182104759358,0.322601916376,0.154278498728,0.20736380182,0.090785481928]
Offsets = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
Bandnames = ['CoastalBlue', 'Blue','Green','Yellow', 'Red', 'RedEdge','NIR1', 'NIR2']
wavelengths = [427.3, 477.9, 546.2, 607.8, 658.8, 723.7, 832.5, 908.0]

Metadata = mul_imgfile.Metadata

Metadata.AddItem, 'data gain values', Gains
Metadata.AddItem, 'data offset values', Offsets
Metadata.updateItem, 'Band names', Bandnames
Metadata.AddItem, 'wavelength', wavelengths
Metadata.AddItem, 'wavelength units', 'nanometers'



radioTask = ENVITask('RadiometricCalibration')
radioTask.Input_Raster = mul_imgfile
radioTask.Output_Data_Type = 'Double'
radioTask.Output_Raster_URI = e.GetTemporaryFilename()
radioTask.execute



spectraltask = ENVITask('SpectralIndices')
spectraltask.Input_Raster = radioTask.Output_raster
spectralTask.INDEX = ['Normalized Difference Vegetation Index','WorldView Built-Up Index']
Spectraltask.Output_raster_uri = "D:\informalsettlements\banglore\mosaics\ndvi_wbi"
Spectraltask.execute

; generate a mask

;mask = (Spectraltask.output_raster.GetData(BAND=0) le .4 AND Spectraltask.output_raster.GetData(BAND=1) ge -.4)
;maskRaster = ENVIRaster(mask, URI="D:\informalsettlements\banglore\mosaics\mask_mosaic", SPATIALREF = mul_imgfile.spatialref )
;maskRaster.Save

;print, maskRaster.nrow
;print, maskRaster.ncol

end