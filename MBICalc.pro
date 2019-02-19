PRO MBICalc
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

  envi=ENVI(/Headless)

  ;;imgfile = "D:\informalsettlements\banglore\RGBmax\mosaicrgbmax"
  ;; imgfile = DIALOG_PICKFILE(/READ) 
  ;;foreach file, batchfiles do begin
    
    
  ;batchfiles = ["D:\informalsettlements\banglore\Road Sections to Clip\MUL\clp1.tif"]
  batchfiles = FILE_SEARCH('D:\informalsettlements\banglore\Road Sections to Clip\MUL\', '*.tif')
  

; Note the zero-indexing.

  foreach file, batchfiles[0:n_elements(batchfiles)-1] do begin
  ;foreach file, batchfiles[31] do begin
    mul_imgfile  = envi.OpenRaster(file)
    
; Radiometric Calibration


    file_delete, 'C:\scratch\blore\', /RECURSIVE,  /ALLOW_NONEXISTENT, /QUIET
   if (~ FILE_TEST('C:\scratch\blore\', /DIRECTORY)) then FILE_MKDIR, 'C:\scratch\blore\'
    CD, 'C:\scratch\blore\'

 
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
    radioTask.Output_Raster_URI = 'C:\scratch\blore\' + strcompress(File_basename(file, ".tif") + "_rad")
    radioTask.execute
    

; Create Spectral Indices

    spectraltask = ENVITask('SpectralIndices')
    spectraltask.Input_Raster = radioTask.Output_raster
    spectralTask.INDEX = ['Normalized Difference Vegetation Index','WorldView Built-Up Index']
    Spectraltask.Output_raster_uri = 'C:\scratch\blore\' + strcompress(File_basename(file, ".tif") + "_spect")
    Spectraltask.execute
    
    ; generate a mask

    mask = (Spectraltask.output_raster.GetData(BAND=0) le .4 AND Spectraltask.output_raster.GetData(BAND=1) ge -.4)
    maskRaster = ENVIRaster(mask, URI=envi.GetTemporaryFilename())
    maskRaster.Save
    
    ;radrasterWithMask = ENVIMaskRaster(radioTask.Output_raster, maskRaster)
    
    ; Get the task from the catalog of ENVITasks

;    maskrasterTask = ENVITask('MaskRaster')
;    maskrasterTask.DATA_IGNORE_VALUE = 0
;    masktrasterTask.INPUT_MASK_RASTER =  maskRaster
;    maskrasterTask.INPUT_RASTER = radioTask.Output_raster
;    maskrasterTask.OUTPUT_RASTER_URI = e.GetTemporaryFilename()
;    Task.Execute    
    

    radfile = envi.openRaster('C:\scratch\blore\' + strcompress(File_basename(file, ".tif") + "_rad"))
    radfile_fid = ENVIRasterToFID(radfile)
    envi_file_query, radfile_fid, DIMS=radfile_dims, NB=radfile_nb, BNAMES=radfile_bnames, FNAME=radfile_fname



    ;rgbmax_fid = ENVIRasterToFID(mul_imgfile)
    ;envi_file_query, rgbmax_fid, DIMS=rgbmax_dims, NB=rgbmax_nb, BNAMES=rgbmax_bnames, FNAME=rgbmax_fname

    envi_doit, 'envi_mask_apply_doit', FID=radfile_fid, DIMS=radfile_dims, POS=Lindgen(radfile_nb), $
      VALUE=0, M_FID=ENVIRasterToFID(maskraster), M_POS=[0], $
      OUT_BNAME='Masked ('+radfile_bnames+')', $
      R_FID=masked01_fid, OUT_NAME='C:\scratch\blore\' + strcompress(File_basename(file, ".tif") + "_urbmasked"), /INVISIBLE
      
 
 
 ;;CD, 'D:\informalsettlements\banglore\MBI'

 
    envi_doit, 'math_doit', FID=[masked01_fid,masked01_fid,masked01_fid], DIMS=radfile_dims, POS=[4,2,1], $
             OUT_BNAME='Band Math ('+File_basename(radfile_fname)+')', $
             EXP='b1>b2>b3', R_FID=rgbmax_fid, OUT_NAME=envi.getTemporaryFilename(), /INVISIBLE
   
    envi_file_query, rgbmax_fid, DIMS=rgbmax_dims, NB=rgbmax_nb, BNAMES=rgbmax_bnames, FNAME=rgbmax_fname

    mul_imgfile.close
    radfile.close
    Spectraltask.Output_raster.close
    
    
 ; initialise files for 0,90,45 and 135 structural elements.
    
    horizfid = [rgbmax_fid]
    vertfid = [rgbmax_fid]
    rotdiagfid = [rgbmax_fid]
    diagfid = [rgbmax_fid]
    
  

    ; Perform convolution/morphological filtering
    ; 2-50 by 5 is the size range for the structural element.

  for I = 2,50,5 do begin 
   envi_doit, 'morph_doit', FID=rgbmax_fid, DIMS=rgbmax_dims, POS=Lindgen(rgbmax_nb), $
      OUT_BNAME='Open ('+rgbmax_bnames+')', $
     METHOD=2, GRAY=1, KERNEL=Fltarr(1,I)+1.0, R_FID=filter01_fid, OUT_NAME= STRCOMPRESS("Horizon_"+STRING(I), /REMOVE_ALL), /INVISIBLE 
   ENVI_Doit, 'Math_Doit', FID = [rgbmax_fid, filter01_fid], DIMS = rgbmax_dims, POS = [0,0], EXP = 'b1 - b2', R_FID=th_horiz_fid,  OUT_NAME = strcompress("th_h_"+ string(I), /REMOVE_ALL), /INVISIBLE
     horizfid = [horizfid, th_horiz_fid]
   envi_doit, 'morph_doit', FID=rgbmax_fid, DIMS=rgbmax_dims, POS=Lindgen(rgbmax_nb), $
     OUT_BNAME='Open ('+rgbmax_bnames+')', $
     METHOD=2, GRAY=1, KERNEL=Fltarr(I,1)+1.0, R_FID=filter01_fid, OUT_NAME=STRCOMPRESS("VertOPEN_"+STRING(I), /REMOVE_ALL), /INVISIBLE 
   ENVI_Doit, 'Math_Doit', FID = [rgbmax_fid, filter01_fid], DIMS = rgbmax_dims, POS = [0,0], EXP = 'b1 - b2', R_FID=th_vert_fid,  OUT_NAME = strcompress("th_v_"+ string(I), /REMOVE_ALL), /INVISIBLE
     vertfid = [vertfid, th_vert_fid] 
   envi_doit, 'morph_doit', FID=rgbmax_fid, DIMS=rgbmax_dims, POS=Lindgen(rgbmax_nb), $
     OUT_BNAME='Open ('+rgbmax_bnames+')', $
     METHOD=2, GRAY=1, KERNEL=ROTATE(IDENTITY(I),1), R_FID=filter01_fid, OUT_NAME=STRCOMPRESS("Rotdiag_"+STRING(I), /REMOVE_ALL), /INVISIBLE 
   ENVI_Doit, 'Math_Doit', FID = [rgbmax_fid, filter01_fid], DIMS = rgbmax_dims, POS = [0,0], EXP = 'b1 - b2', R_FID=th_rotdiag_fid,  OUT_NAME = strcompress("th_rotdiag_"+ string(I), /REMOVE_ALL), /INVISIBLE
     rotdiagfid = [rotdiagfid, th_rotdiag_fid] 
   envi_doit, 'morph_doit', FID=rgbmax_fid, DIMS=rgbmax_dims, POS=Lindgen(rgbmax_nb), $
     OUT_BNAME='Open ('+rgbmax_bnames+')', $
     METHOD=2, GRAY=1, KERNEL=IDENTITY(I), R_FID=filter01_fid, OUT_NAME=STRCOMPRESS("Diag_"+STRING(I), /REMOVE_ALL), /INVISIBLE 
   ENVI_Doit, 'Math_Doit', FID = [rgbmax_fid, filter01_fid], DIMS = rgbmax_dims, POS = [0,0], EXP = 'b1 - b2', R_FID=th_diag_fid,  OUT_NAME = strcompress("th_diag_"+ string(I), /REMOVE_ALL), /INVISIBLE
     diagfid = [diagfid, th_diag_fid] 
    endfor
    
    numfiles = diagfid.length

    ;; Differential Morphological Profiles.

    dmphorizfid = []
    dmpvertfid = []
    dmprotdiagfid = []
    dmpdiagfid = []
    
   for I = 0, numfiles-2 do begin
    envi_file_query, horizfid[I], DIMS=rgbmax_dims, NB=rgbmax_nb, FNAME=rgbmax_fname
    ENVI_Doit, 'Math_Doit', FID = [horizfid[I], horizfid[I+1]], DIMS = rgbmax_dims, POS = [0,0], EXP = 'abs(b1 - b2)', R_FID=math01_fid,  OUT_NAME = strcompress("dmp_h_"+ string(I), /REMOVE_ALL), /INVISIBLE 
    dmphorizfid = [dmphorizfid, math01_fid]
    ENVI_Doit, 'Math_Doit', FID = [vertfid[I], vertfid[I+1]], DIMS = rgbmax_dims, POS = [0,0], EXP = 'abs(b1 - b2)', R_FID=math01_fid, OUT_NAME = strcompress("dmp_v_"+ string(I), /REMOVE_ALL), /INVISIBLE
    dmpvertfid = [dmpvertfid, math01_fid]
    ENVI_Doit, 'Math_Doit', FID = [rotdiagfid[I], rotdiagfid[I+1]], DIMS = rgbmax_dims, POS = [0,0], EXP = 'abs(b1 - b2)', R_FID=math01_fid, OUT_NAME = strcompress("dmp_rd_"+ string(I), /REMOVE_ALL), /INVISIBLE
    dmprotdiagfid = [dmprotdiagfid, math01_fid]
    ENVI_Doit, 'Math_Doit', FID = [diagfid[I], diagfid[I+1]], DIMS = rgbmax_dims, POS = [0,0], EXP = 'abs(b1 - b2)', R_FID=math01_fid, OUT_NAME = strcompress("dmp_d_"+ string(I), /REMOVE_ALL), /INVISIBLE
    dmpdiagfid = [dmpdiagfid, math01_fid]
   endfor
   
   fidarray = [dmphorizfid, dmpvertfid, dmprotdiagfid, dmpdiagfid]

   ;; Export data
   
  envi_doit, 'cf_doit', DIMS=rgbmax_dims, FID=fidarray, POS= FLTARR(fidarray.LENGTH), out_name='dmp_cf', R_FID=dmp_fid, /INVISIBLE
  ENVI_File_Query, dmp_fid, DIMS=dims, NB=nb
  
  CD, 'D:\informalsettlements\banglore\MBI

  ;; Sum data.
  
  ENVI_Doit, 'ENVI_Sum_Data_Doit',  DIMS = dims, FID = dmp_fid, POS = Lindgen(nb), COMPUTE_FLAG = [0,0,1,0,0,0,0,0], OUT_DT = 4, OUT_BNAME = ['Mean'], OUT_NAME = strcompress(File_basename(file, ".tif")+'_mbi_avg', /REMOVE_ALL), R_FID=mbi_fid, /INVISIBLE
  
;  img = ENVI_GET_DATA(fid=mbi_fid, DIMS=dims, pos=[0])
;  img2 = ENVIRaster(CANNY(img), URI=strcompress(File_basename(file, ".tif")+'_canny', /REMOVE_ALL), nbands=1)
;  img2.Save
;  img2.close
;  img.close
  
  close, /all

  ;; Cleanup
  
  ;filestoremove = [file_search('C:\scratch\blore\', 'Horizon*'), file_search('C:\scratch\blore', 'Vert*'), file_search('C:\scratch\blore\', 'Rotdiag*'),file_search('C:\scratch\blore\', 'diag*'), file_search('C:\scratch\blore\', 'th*'), file_search('C:\scratch\blore\', 'dmp*')]
  ;file_delete, filestoremove, /ALLOW_NONEXISTENT
  file_delete, 'C:\scratch\blore\', /RECURSIVE,  /ALLOW_NONEXISTENT, /QUIET
  endforeach
  
    envi.close  
END