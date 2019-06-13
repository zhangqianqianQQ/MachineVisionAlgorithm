# PCA_denoising
The PCA denoising matlab algorithm used in the publication "Principal component analysis for fast and model-free denoising of multi b-value diffusion-weighted MR images" in physics in medicine and biology in 2019, written by Gurney-Champion et al.

The code requieres Matlab

Denoise IVIM data according to: 
"Principal component analysis for fast and model-free denoising of multi b-value diffusion-weighted MR images"
by Gurney-Champion et al. Investigative Radiology 2019 DOI: XXX

[denoised_data, PCs] = PCA_denoise_DWI(data,b_values,options) uses PCA-denoising to denoise a multi-b-value DWI data-set.

Output:
denoised_data: the denoised data
PCs: the number of PCs taken along to generate the data

Input:
data can be 2D slice or 3D volume and should be sorted as follow:
2D data: n x m x b matrix, with 2D (n x m) data from b b-values/directions/repeated measures *note that PCA denoising has only been ested for 3D data, to ensure sufficient voxels to determine the signal fractions. Potentially, the performance on 2D data is less% 3D data: n x m x p x b matrix, with 3D (n x m x p) data from b b-values/directions/repeated measures
b_values: the b-value vector corresponding to the last column dimensions
options: an optional structure with various options
options.plot --> put to 1 to show plots of some steps
options.cutoff --> a cutoff value; if the signal intensity of the mean image of the lowest b-value is below this value, this data is set to zero and removed from the PCA analysis.
options.directions --> a vector of length b (where b= length final dimension of data), repressenting which measurements where done under similar diffusion directions. When options.directions is given, the algorithm will also sort data according to directional index when calculating ideal cut-off value for number of PCs. Please make sure same directions have same indexes. 
By default zero-filled entries of the data corresponding to the first b-value will be ignored during PCA-denoising


Please refer to the physics in medicine and biology article if used.
