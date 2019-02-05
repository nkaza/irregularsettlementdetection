PRO MSICalc
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

  envi=ENVI()

  imgfile = "D:\informalsettlements\banglore\work\maxRGB_ndvi_masked"

  ;;foreach file, batchfiles do begin


  
    rasterloop = envi.OpenRaster(imgfile)
    rasterloop_fid = ENVIRasterToFID(rasterLoop)
    envi_file_query, rasterloop_fid, DIMS=rasterloop_dims, NB=rasterloop_nb, BNAMES=rasterloop_bnames, FNAME=rasterloop_fname
    
    horizfid = [rasterloop_fid]
    vertfid = [rasterloop_fid]
    rotdiagfid = [rasterloop_fid]
    diagfid = [rasterloop_fid]
    
CD, 'C:\scratch\blore\MSI'

    ; Perform convolution/morphological filtering
  for I = 2,50,2 do begin 
   envi_doit, 'morph_doit', FID=rasterloop_fid, DIMS=rasterloop_dims, POS=Lindgen(rasterloop_nb), $
      OUT_BNAME='Open ('+rasterloop_bnames+')', $
     METHOD=3, GRAY=0, KERNEL=Fltarr(1,I)+1.0, R_FID=filter01_fid, OUT_NAME= STRCOMPRESS("Horizon_"+STRING(I), /REMOVE_ALL), /INVISIBLE 
   ENVI_Doit, 'Math_Doit', FID = [rasterloop_fid, filter01_fid], DIMS = rasterloop_dims, POS = [0,0], EXP = 'b2 - b1', R_FID=th_horiz_fid,  OUT_NAME = strcompress("th_h_"+ string(I), /REMOVE_ALL), /INVISIBLE
     horizfid = [horizfid, th_horiz_fid]
   envi_doit, 'morph_doit', FID=rasterloop_fid, DIMS=rasterloop_dims, POS=Lindgen(rasterloop_nb), $
     OUT_BNAME='Open ('+rasterloop_bnames+')', $
     METHOD=3, GRAY=0, KERNEL=Fltarr(I,1)+1.0, R_FID=filter01_fid, OUT_NAME=STRCOMPRESS("Vert_"+STRING(I), /REMOVE_ALL), /INVISIBLE 
   ENVI_Doit, 'Math_Doit', FID = [rasterloop_fid, filter01_fid], DIMS = rasterloop_dims, POS = [0,0], EXP = 'b2 - b1', R_FID=th_vert_fid,  OUT_NAME = strcompress("th_v_"+ string(I), /REMOVE_ALL), /INVISIBLE
   vertfid = [vertfid, th_vert_fid]
   envi_doit, 'morph_doit', FID=rasterloop_fid, DIMS=rasterloop_dims, POS=Lindgen(rasterloop_nb), $
     OUT_BNAME='Open ('+rasterloop_bnames+')', $
     METHOD=3, GRAY=0, KERNEL=ROTATE(IDENTITY(I),1), R_FID=filter01_fid, OUT_NAME=STRCOMPRESS("Rotdiag_"+STRING(I), /REMOVE_ALL), /INVISIBLE 
   ENVI_Doit, 'Math_Doit', FID = [rasterloop_fid, filter01_fid], DIMS = rasterloop_dims, POS = [0,0], EXP = 'b2 - b1', R_FID=th_rotdiag_fid,  OUT_NAME = strcompress("th_rotdiag_"+ string(I), /REMOVE_ALL), /INVISIBLE
   rotdiagfid = [rotdiagfid, th_rotdiag_fid]
   envi_doit, 'morph_doit', FID=rasterloop_fid, DIMS=rasterloop_dims, POS=Lindgen(rasterloop_nb), $
     OUT_BNAME='Open ('+rasterloop_bnames+')', $
     METHOD=3, GRAY=0, KERNEL=IDENTITY(I), R_FID=filter01_fid, OUT_NAME=STRCOMPRESS("Diag_"+STRING(I), /REMOVE_ALL), /INVISIBLE 
   ENVI_Doit, 'Math_Doit', FID = [rasterloop_fid, filter01_fid], DIMS = rasterloop_dims, POS = [0,0], EXP = 'b2 - b1', R_FID=th_diag_fid,  OUT_NAME = strcompress("th_diag_"+ string(I), /REMOVE_ALL), /INVISIBLE
   diagfid = [diagfid, th_diag_fid] 
    endfor
    
    numfiles = diagfid.length

    
    dmphorizfid = []
    dmpvertfid = []
    dmprotdiagfid = []
    dmpdiagfid = []
    
   for I = 0, numfiles-2 do begin
    envi_file_query, horizfid[I], DIMS=rasterloop_dims, NB=rasterloop_nb, FNAME=rasterloop_fname
    ENVI_Doit, 'Math_Doit', FID = [horizfid[I], horizfid[I+1]], DIMS = rasterloop_dims, POS = [0,0], EXP = 'abs(b1 - b2)', R_FID=math01_fid,  OUT_NAME = strcompress("dmp_h_"+ string(I), /REMOVE_ALL), /INVISIBLE 
    dmphorizfid = [dmphorizfid, math01_fid]
    ENVI_Doit, 'Math_Doit', FID = [vertfid[I], vertfid[I+1]], DIMS = rasterloop_dims, POS = [0,0], EXP = 'abs(b1 - b2)', R_FID=math01_fid, OUT_NAME = strcompress("dmp_v_"+ string(I), /REMOVE_ALL), /INVISIBLE
    dmpvertfid = [dmpvertfid, math01_fid]
    ENVI_Doit, 'Math_Doit', FID = [rotdiagfid[I], rotdiagfid[I+1]], DIMS = rasterloop_dims, POS = [0,0], EXP = 'abs(b1 - b2)', R_FID=math01_fid, OUT_NAME = strcompress("dmp_rd_"+ string(I), /REMOVE_ALL), /INVISIBLE
    dmprotdiagfid = [dmprotdiagfid, math01_fid]
    ENVI_Doit, 'Math_Doit', FID = [diagfid[I], diagfid[I+1]], DIMS = rasterloop_dims, POS = [0,0], EXP = 'abs(b1 - b2)', R_FID=math01_fid, OUT_NAME = strcompress("dmp_d_"+ string(I), /REMOVE_ALL), /INVISIBLE
    dmpdiagfid = [dmpdiagfid, math01_fid]
   endfor
   
   fidarray = [dmphorizfid, dmpvertfid, dmprotdiagfid, dmpdiagfid]
   
  envi_doit, 'cf_doit', DIMS=rasterloop_dims, FID=fidarray, POS= FLTARR(fidarray.LENGTH), out_name='dmp_cf', R_FID=dmp_fid, /INVISIBLE
  ENVI_File_Query, dmp_fid, DIMS=dims, NB=nb
  ENVI_Doit, 'ENVI_Sum_Data_Doit',  DIMS = dims, FID = dmp_fid, POS = Lindgen(nb), COMPUTE_FLAG = [0,0,1,0,0,0,0,0], OUT_DT = 4, OUT_BNAME = ['Mean'], OUT_NAME = 'msi_avg'
  
  
  filestoremove = [file_search('C:\scratch\blore\MSI', 'Horizon*'), file_search('C:\scratch\blore\MSI', 'Vert*'), file_search('C:\scratch\blore\MSI', 'Rotdiag*'),file_search('C:\scratch\blore\MSI', 'diag*'), file_search('C:\scratch\blore\MSI', 'dmp*'), file_search('C:\scratch\blore\MSI', 'th*')]
  file_delete, filestoremove, /ALLOW_NONEXISTENT

      
END