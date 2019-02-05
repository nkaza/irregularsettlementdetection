PRO createmasked
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
  
  
file = "D:\informalsettlements\banglore\Road Sections to Clip\MUL\clp1.tif"

mul_imgfile = envi.OpenRaster(file)

Gains = [0.196525454545,0.328465561694,0.216539206349,0.182104759358,0.322601916376,0.154278498728,0.20736380182,0.090785481928]
Offsets = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
Bandnames = ['Coastalblue', 'blue','GREEN','yellow', 'RED', 'rededge','NIR1', 'NIR2']

Metadata = mul_imgfile.Metadata

Metadata.AddItem, 'data gain values', Gains
Metadata.AddItem, 'data offset values', Offsets
Metadata.updateItem, 'Band names', Bandnames

file_delete, 'C:\scratch\blore\', /RECURSIVE
FILE_MKDIR, 'C:\scratch\blore\'

CD, 'C:\scratch\blore\'

Task = ENVITask('RadiometricCalibration')
Task.Input_Raster = mul_imgfile
Task.Output_Data_Type = 'Double'
Task.Output_Raster_URI = 'C:\scratch\blore\' + strcompress(File_basename(file, ".tif") + "_rad")

Task.execute

radfile = envi.openRaster('C:\scratch\blore\' + strcompress(File_basename(file, ".tif") + "_rad"))
radfile_fid = ENVIRasterToFID(radfile)
envi_file_query, radfile_fid, DIMS=radfile_dims, NB=radfile_nb, BNAMES=radfile_bnames, FNAME=radfile_fname

envi_doit, 'math_doit', FID=[radfile_fid,radfile_fid], DIMS=radfile_dims, POS=[0,5], $
  OUT_BNAME='WVBI ('+File_basename(radfile_fname)+')', $
  EXP='(b1-b2)/(b1+b2)', R_FID=wvbi_fid, OUT_NAME='C:\scratch\blore\' + strcompress(File_basename(file, ".tif") + "_wvbi")

envi_doit, 'math_doit', FID=[radfile_fid,radfile_fid], DIMS=radfile_dims, POS=[7,4], $
    OUT_BNAME='NDVI ('+File_basename(radfile_fname)+')', $
    EXP='(b1-b2)/(b1+b2)', R_FID=wvndvi_fid, OUT_NAME='C:\scratch\blore\' + strcompress(File_basename(file, ".tif") + "_ndvi")

  envi_doit, 'math_doit', FID=[wvbi_fid,wvndvi_fid], DIMS=radfile_dims, POS=[0,0], $
    OUT_BNAME='urbanmask ('+File_basename(radfile_fname)+')', $
    EXP='(b1 GE -.4)*(b2 LE 0.4)', R_FID=mask_fid, OUT_NAME='C:\scratch\blore\' + strcompress(File_basename(file, ".tif") + "_urbmask")

mulfile_fid = ENVIRasterToFID(mul_imgfile)
envi_file_query, mulfile_fid, DIMS=mulfile_dims, NB=mulfile_nb, BNAMES=mulfile_bnames, FNAME=mulfile_fname

envi_doit, 'envi_mask_apply_doit', FID=mulfile_fid, DIMS=mulfile_dims, POS=Lindgen(mulfile_nb), $
    VALUE=0, M_FID=mask_fid, M_POS=[0], $
    OUT_BNAME='Masked ('+mulfile_bnames+')', $
    R_FID=masked01_fid, OUT_NAME='C:\scratch\blore\' + strcompress(File_basename(file, ".tif") + "_urbmasked")


end