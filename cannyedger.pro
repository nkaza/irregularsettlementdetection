pro cannyedger

imgfile = "C:\scratch\blore\MBI\pansharp_mbi_avg_aftermask"
envi=ENVI()


CD, 'C:\scratch\blore\MBI'

rasterfile = envi.OpenRaster(imgfile)
rasterfile_fid = ENVIRasterToFID(rasterfile)
envi_file_query, rasterfile_fid, DIMS=rasterfile_dims, NB=rasterfile_nb, BNAMES=rasterfile_bnames, FNAME=rasterfile_fname

img = ENVI_GET_DATA(fid=rasterfile_fid, DIMS=rasterfile_dims, pos=[0])
img2 = ENVIRaster(CANNY(img), URI='canny_pansharp_aftermask', nbands=1)
img2.Save

END