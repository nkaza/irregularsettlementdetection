pro mbicalculator


  imgfile = DIALOG_PICKFILE(/READ)  
  
  envi=ENVI()

  
  OrigRaster = envi.OpenRaster(imgfile)
  
  CD, 'C:\scratch\blore\MBI'

  newfile = envi.GetTemporaryFilename()

  
  maxRGBRaster = ENVIRaster(URI=newFile, NROWS=OrigRaster.NROWS, NCOLUMNS=OrigRaster.NCOLUMNS, NBANDS=1, DATA_TYPE='double')
    
    
    tileIterator = OrigRaster.CreateTileIterator(MODE='spectral', BANDS=[1,2,4])
    
    count = 0L
    
    foreach tile, tileIterator Do Begin
      count++
      print, ''
      print, 'Tile number'
      print, count
      processedTile = tile[*,0]>tile[*,1]>tile[*,2]
      currentSubRect = tileIterator.CURRENT_SUBRECT
      MaxRGBRaster.SetData, processedTile, SUB_RECT=currentSubRect
    endforeach
    
    MaxRGBRaster.Save
    
    ; Display the new raster
    View = e.GetView()
    Layer = View.CreateLayer(MaxRGBRaster)
    
 END
    