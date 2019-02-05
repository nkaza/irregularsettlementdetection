PRO makedmp
  compile_opt idl2
  on_error, 2

  ; General error handler
  Catch, error
  if (error ne 0) then begin
    Catch, /CANCEL
    if obj_valid(envi) then $
      envi.ReportError, "Error: " + !error_state.msg
    message, /RESET
    return
  endif
  
  
  envi = envi()
  
  dirs = FILE_SEARCH('C:\scratch', '*stuff')
  
 
  cd, dirs[0]
  
  files = file_basename(file_search('dmp*'), ".hdr")
  files = file_basename(files, ".enp")
  files = files[uniq(files,sort(files))]
  
  FIDARRAY = []
  
  for I= 0, files.LENGTH -1 do begin
    ENVI_OPEN_FILE, files[I], R_FID= fid
    FIDARRAY = [FIDARRAY, FID]
  endfor
  envi_file_query, fidarray[0], DIMS=dmp_dims, NB=dmp_nb, BNAMES=dmp_bnames, FNAME=dmp_fname
 envi_doit, 'cf_doit', DIMS=dmp_dims, FID=fidarray, POS= FLTARR(fidarray.LENGTH), out_name='dmp_cf', R_FID=dmp_fid, /INVISIBLE
 ENVI_File_Query, dmp_fid, DIMS=dims, NB=nb
 
 CD, 'D:\informalsettlements\banglore\MBI

 ENVI_Doit, 'ENVI_Sum_Data_Doit',  DIMS = dims, FID = dmp_fid, POS = Lindgen(nb), COMPUTE_FLAG = [0,0,1,0,0,0,0,0], OUT_DT = 4, OUT_BNAME = ['Mean'], OUT_NAME = 'clp18_mbi_avg', R_FID=mbi_fid, /INVISIBLE
 img = ENVI_GET_DATA(fid=mbi_fid, DIMS=dims, pos=[0])
 img2 = ENVIRaster(CANNY(img), URI= 'clp18_canny', nbands=1)
 img2.Save
 img2.close
  
  
close, /all
  
  
  end
  