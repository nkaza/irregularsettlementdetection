
# Introduction

This is a collection of scripts used to detect irregular settlements in Banglore in India. The main idea is to use high resolution satellite images (2m - 0.5m) and machine learning techinque such as boosted trees. Due to licensing restrictions, the input and training datasets are not provided. Please adapt the code as necessary for your own datasets.

The scripts rely on R and ENVI + IDL . While R is open source and has a GPL license, ENVI + IDL is a proprietary remote sensing software. Please acquire appropriate licences before using the code.


# Workflow

1. Preprocess the raw image dataset (preprocessing_banlgore.pro)
2. Create a mask (water/roads) and apply it (createmasked.pro) 
3. Calculate various indices  (MBICalc.pro, makedmp.pro, MSICalc.pro, texturecalc.pro/py, cannyedger.pro lacunarity.R, localLmetrics.R).
4. If the metrics are calculated on small sections of the image, mosaic them for the whole study area (mosaicbath.R/pro)
5. Apply machine learning algorithms (machinelearningClassifier\*.R)


## Preprocessing 

The dataset used for this analsysis is 8-band 2m resolution data from Digital Globe World View 2 images, for 2000 sq.km. The images are collected in April 2016. 

A number of preprocessing steps are required to make the image useful for analysis. 

1. Radiometric calibration. See e.g. https://www.harrisgeospatial.com/docs/calibratingimagestutorial.html
2. Assembling ancilliary vector and raster datasets (such a medium resolution land cover from Landsat, road network from Openstreetmap) etc.
3. Image registration and reprojection. See e.g. https://www.harrisgeospatial.com/docs/imageregtutorial.html

Not all of the above are required. Please use appropriately. Cloud cover on these images are minimal to non-existent thus no corrections were performed.

## Creating a mask

Vector data Road, rail, park and other other non-urban landuses are obtained from Openstreetmap and converted to raster with appropriate resolution (of the original image). createmaked.pro applies a mask on the pixels so that they are not used in the training dataset.


## Ceating Different Indices/Layers/Variables

The following indices are used in this analysis

1. Morphological Building Index (mbicalculator.pro) see https://www.taylorfrancis.com/books/9780429888564/chapters/10.1201%2F9781138586642-3
2. Morphological Shadow Index (MSICalc.pro) see https://www.umbc.edu/rssipl/people/aplaza/Papers/Conferences/2016.CMMSE.Morphological.pdf
3. Differenial Morphological Profiles (makedmp.pro) see https://ieeexplore.ieee.org/abstract/document/6056582
4. Different Spectral Indices such as Normalised  Built Up Index,  Normalised Vegetation Index https://www.harrisgeospatial.com/docs/NDVI.html, https://www.harrisgeospatial.com/docs/backgroundotherindices.html#WorldVie
5. Lacunarity based on thresholding MBI and MSI (lacunarity.R) see https://doi.org/10.1111/j.1538-4632.2006.00691.x
6. Harlick Textures (need QGIS/Orfeo Toolbox for this, texutrecalc.py). These include 

Simple Haralick Texture Features: This group of parameters defines the 8 local Haralick texture feature output image. The image channels are: Energy, Entropy, Correlation, Inverse Difference Moment, Inertia, Cluster Shade, Cluster Prominence and Haralick Correlation.

Advanced Texture Features: This group of parameters defines the 10 advanced texture feature output image. The image channels are: Mean, Variance, Dissimilarity, Sum Average, Sum Variance, Sum Entropy, Difference of Entropies, Difference of Variances, IC1 and IC2.

see https://www.orfeo-toolbox.org/CookBook/Applications/app_HaralickTextureExtraction.html

7. Building size indices based on thresholding MBI (localLmetrics.R) see https://rdrr.io/github/r-spatialecology/landscapemetrics/f/README.md

These indices include 

8. Number of Edges (cannyedger.pro/cannybatch.pro) see https://en.wikipedia.org/wiki/Canny_edge_detector

Other metrics are also calcuated such as distance to nearest roads, distance to water bodies, distance to key landmarks such as cemetaries, rail roads etc.  Please make sure that all the rasters are properly aligned and have the same resolution. Positional differences will introduce errors in the classification.

assemblebands.pro will assemble vairous bands into a single image stack.


## Machine Learning Classification

Once all the variables are assembled, we use Caret package in R to apply different machine learning models to classify the images. The training data is assembled from vector boundary files (polygons). The training polygons include different categories such as Regular, Irregular Multi Story, Irregular Single Story, Irregular Semi Permanent and Irregular Temporary.

The scripts (machinelearningClassifier\*.R) assembles various bands/variables, extracts the training dataset, splits it into testing and validation datasets and performs predictions using different algorithms (KNN, gradient boosted trees etc.)













