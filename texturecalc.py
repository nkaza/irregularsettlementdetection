import os
import glob
import processing

mbifolder = "D:\\informalsettlements\\banglore\\MBI"

texfolder = "D:\\informalsettlements\\banglore\\haralick5\\"

os.chdir(mbifolder)


# Run through a list of files. For parameters associated with Haralick textures see https://docs.qgis.org/2.18/en/docs/user_manual/processing_algs/otb/feature_extraction.html#haralick-texture-extraction

for inputmbi in list(set(glob.glob("*"))-set(glob.glob("*.*"))):
    outfile = texfolder + inputmbi  + "_texture.tif"
    print outfile
    if not os.path.exists(outfile):
        outputs_QGISRASTERLAYERSTATISTICS_1=processing.runalg('qgis:rasterlayerstatistics', inputmbi,None)
        processing.runalg('otb:haralicktextureextraction', inputmbi,1.0,128.0,5.0,5.0,1.0,1.0,outputs_QGISRASTERLAYERSTATISTICS_1['MIN'],outputs_QGISRASTERLAYERSTATISTICS_1['MAX'],16.0,1,outfile)

