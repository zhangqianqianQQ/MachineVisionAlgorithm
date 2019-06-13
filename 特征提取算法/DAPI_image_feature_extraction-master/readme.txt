Morphological features from DAPI image for egg chamber stage identification (Matlab)
*****************************************************
This software has been tested on Matlab 2013b and newer. Note that the Matlab installation should include the Image Processing Toolbox. 	

If you have questions about the use of this package, feel free to contact 
Qiuping Xu: qx0731@gmail.com

This is the supplementary material for paper: D.Jia, Q.Xu, Q.Xie, W.Mio and W, Deng. Drosophila egg chamber stage identification from DAPI images.
You are welcome to use the software freely. If you use it for a publication, we would appreciate an acknowledgement by referencing our paper.

*****************************************************

This algorithm was developed for extracting morphological features from DAPI image. The algorithm uses a DAPI image the input and through image process to output several image features (egg chamber size, egg chamber ratio, egg chamber orientation, oocyte size, follicle cell distribution, blob-like chromosomes and centripetal cell migration). A few remarks that might be useful for user of the software.
(a) In this version, before you apply our program, please make sure you convert your stack figure into individual images and use the DAPI channel one. Please save this DAPI image into .TIF format. Feel free to use open source software ImageJ (http://imagej.nih.gov/ij/) to fulfil those goals.
(b) The algorithm first detected the egg chamber area and egg chamber ratio for all specimens. Based on cell size, we further divided into subcategories to detect other features. 
(c) In addition to the algorithm we developed, we adopted the algorithm mathwork file exchange for InsidePolyFolder and chanvese. 
*****************************************************
Step 1. 
Download the package and unzip this into folder `Image_feature`
******************
Step 2.
a. In addition to the algorithm we developed, there is a subfolder called `data_ready`. Please place the DAPI images in .tif format into this folder.
******************
Step 3.  
a. Open Matlab and navigate to the directory `Image_feature\InsidePolyFolder`
b. Within Maltab, execute the following command to mex the c code to Matlab executable program
>> mex insidepoly_dblengine.c
>> mex insidepoly_sglengine.c
******************
Step 4.
a. Navigate back to ` Image_feature`
b. Execute the command 
>> [area ratio oocyte_size distance]=feature_extraction(filename);
Example: [area ratio oocyte_size distance]=feature_extraction('example1.tif');
REMARK 1:  replace the filename as the name of the .tif files in single quote.

REMARK 2:  consult the paper for more information
1. area is the egg chamber size in mm ^2
2. ratio is the egg chamber ratio
3. oocyte_size gives the oocyte size of that egg chamber in %
4. distance gives the follicle cell distribution 
            Type in variable name to exam the value, for example, area
	    
REMARK 3: Along with the quantitative measurement, this algorithm also provide vision aid pictures for egg chamber orientation, oocyte size, follicle cell distribution, blob-like chromosomes and centripetal cell migration.

REMARK 4: We provide four examples, issue those commands to see those examples

[area ratio oocyte_size distance]=feature_extraction('example1.tif');
[area ratio oocyte_size distance]=feature_extraction('example2.tif');
[area ratio oocyte_size distance]=feature_extraction('example3.tif');
[area ratio oocyte_size distance]=feature_extraction('example4.tif');

Enjoy~
		
