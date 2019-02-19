pro texturecalc


  ; General error handler
  Catch, error
  if (error ne 0) then begin
    Catch, /CANCEL
    if obj_valid(envi) then $
      envi.ReportError, "Error: " + !error_state.msg
    message, /RESET
    return
  endif
  
  ; Initalise

   envi=ENVI(/Headless)
  
  ; Loop through a list of files in D:\informalsettlements\banglore\MBI
  foreach file, batchfiles[0:n_elements(batchfiles)-1] do begin

    batchfiles = FILE_SEARCH('D:\informalsettlements\banglore\MBI', '*.hdr')

  ; Texture types
  
    texturebnames = ['mean', 'variance', 'homogeneity', 'contrast', 'dissimilarity', 'entropy', 'secondmoment', 'correlation']
    
    
    mbifile = envi.openRaster(batchfiles[0])
    mbifile_fid = ENVIRasterToFID(mbifile)
    envi_file_query, mbifile_fid, DIMS=mbifile_dims, NB=mbifile_nb, FNAME=mbifile_fname
    
    outfile_name = "D:\informalsettlements\banglore\haralick\" + strcompress(File_basename(mbifile_fname, "") + "_texture")
    
  ; Texture calculations

    ENVI_DOIT, 'TEXTURE_COOCCUR_DOIT', DIMS=mbifile_dims, DIRECTION=[1,1], FID=mbifile_fid, G_LEVELS=32, KX=5, KY=5, METHOD=[0:7], OUT_BNAME=texturebnames, OUT_NAME=outfile_name, POS=[0:7], R_FID=rfid

   endforeach