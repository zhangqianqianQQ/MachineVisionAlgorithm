This package contains Matlab code for implementing the S3 sharpness measure algorithm. 
Please cite the paper followed if you use this code for your research:

C. Vu, T. Phan, and D. M. Chandler, "S3: A Spectral and Spatial Measure of Local Perceived Sharpness in Natural Images,” IEEE Transaction on Image Processing, 21 (3), September, 2011..

The main function is s3_map.m. This function output the spectral map (s1), spatial map (s2) and the final sharpness map (s3). 
In order to compute the s3 index, please take the average of the 1% hightest values in the S3 map. 
For more details of the algorithm, please refer to one of the two papers above. 