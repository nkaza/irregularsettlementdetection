PRO cannyBATCH
  COMPILE_OPT IDL2
  ; Start the application
  e = ENVI(/HEADLESS)

  ;;; The script uses CANNY function from ENVI See https://www.harrisgeospatial.com/docs/CANNY.html
  
  CD, 'D:\informalsettlements\banglore\MBI'
  batchfiles = FILE_SEARCH('D:\informalsettlements\banglore\MBI', '*.hdr')
  cannyfilesdir = 'D:\informalsettlements\banglore\Canny2\'
  
   foreach file, batchfiles[0:n_elements(batchfiles)-1] do begin
   ;foreach file, batchfiles[0] do begin
      mbi_imgfile  = e.OpenRaster(file)
      mbifile_fid = ENVIRasterToFID(mbi_imgfile)
      envi_file_query, mbifile_fid, DIMS=mbifile_dims, NB=mbifile_dims, BNAMES=mbifile_bnames, FNAME=mbifile_fname
      img = ENVI_GET_DATA(fid=mbifile_fid, DIMS=mbifile_dims, pos=[0])      
      img2 = ENVIRaster(CANNY(img), URI=strcompress(cannyfilesdir + File_basename(mbifile_fname, "")+'_canny', /REMOVE_ALL), INHERITS_FROM=mbi_imgfile)
      img2.save
      img2.close
   endforeach
 end