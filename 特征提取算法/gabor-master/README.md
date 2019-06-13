# Gabor Feature Extraction

The first function named "gaborFilterBank.m" generates a custom-sized Gabor filter bank. It creates a UxV cell array, whose elements are MxN matrices; each matrix being a 2-D Gabor filter. The second function named "gaborFeatures.m" extracts the Gabor features of an input image. It creates a column vector, consisting of the Gabor features of the input image. The feature vectors are normalized to zero mean and unit variance. At the end of each file there is a Show section that plots the filters and shows the filtered images. These are only for illustration purpose, and you can comment them as you wish.


More details can be found in:

M. Haghighat, S. Zonouz, M. Abdel-Mottaleb, "CloudID: Trustworthy cloud-based and cross-enterprise biometric identification," Expert Systems with Applications, vol. 42, no. 21, pp. 7905-7916, 2015.
http://dx.doi.org/10.1016/j.eswa.2015.06.025


(C)	Mohammad Haghighat, University of Miami
	haghighat@ieee.org
	PLEASE CITE THE ABOVE PAPER IF YOU USE THIS CODE.
