-----------------------------------------------------------------------

   Software for Rician noise removal via variance stabilization
                Release ver. 1.1  (14 May 2012)

-----------------------------------------------------------------------

Copyright (c) 2011-2012 Tampere University of Technology. 
All rights reserved.
This work should be used for nonprofit purposes only.

Author:                     Alessandro Foi


web page:                   http://www.cs.tut.fi/~foi/RiceOptVST/


-----------------------------------------------------------------------
 Contents
-----------------------------------------------------------------------

The package implements the method published in [1] and contains
the following files:

*) demo_riceVST_denoising.m : main demo script
*) riceVST.m                : applies (forward) variance-stabilizing 
                              transformation for Rician-distributed
                              data
*) riceVST_EUI.m            : applies exact unbiased inverse of the
                              variance-stabilizing transformation
*) riceVST_sigmaEst.m       : iterative estimation of the sigma
                              parameter of Rician-distributed data
*) function_stdEst.m        : noise standard deviation estimation
                              (additive white Gaussian noise model)
*) ricePairInversion.m      : computes (nu,sigma) pair from (mu,s) pair
*) Rice_VST_A.mat           : MAT-file with transformation 'A'
*) Rice_VST_B.mat           : MAT-file with transformation 'B'
*) t1_icbm_normal_1mm_pn0_rf0.rawb   : BrainWeb T1 phantom [2]

-----------------------------------------------------------------------
 Installation
-----------------------------------------------------------------------

The method can be used with any algorithm for AWGN removal from
volumetric data.
The script  demo_riceVST_denoising.m  already supports the algorithms
 BM4D (Grouping and Collaborative Filtering) [3]
 OB-NLM-3D-WM  (Optimized blockwise NL-means with wavelet mixing) [4]
which can be downloaded from
 http://www.cs.tut.fi/~foi/GCF-BM3D
 http://personales.upv.es/jmanjon/denoising/naonlm3d.zip

These algorithms are assumed to be installed either in the path or
in the following respective subfolders of the folder where the demo
script is installed:  ./bm4d  and  ./naonlm3d

In case the input data is 2-D, the method uses the BM3D image denoising
algorithm, which can be downloaded from 
 http://www.cs.tut.fi/~foi/GCF-BM3D

 
-----------------------------------------------------------------------
 Requirements
-----------------------------------------------------------------------

*) Matlab v.7.1 or later
*) A denoising algorithm for volumetric data (see 'Installation' above)


-----------------------------------------------------------------------
 References
-----------------------------------------------------------------------

[1] A. Foi, "Noise Estimation and Removal in MR Imaging: the 
    Variance-Stabilization Approach", in Proc. 2011 IEEE Int. Sym.
    Biomedical Imaging, ISBI 2011, Chicago (IL), USA, April 2011.

[2] R. Vincent, "Brainweb:  Simulated  brain  database", online at
    http://mouldy.bic.mni.mcgill.ca/brainweb/, 2006.
	
[3] M. Maggioni, V. Katkovnik, K. Egiazarian, A. Foi, "A Nonlocal 
    Transform-Domain Filter for Volumetric Data Denoising and 
    Reconstruction", submitted to IEEE Trans. Image Process., 2011.
	
[4] P. Coupé, P. Yger, S. Prima, P. Hellier, C. Kervrann,
    C. Barillot, "An Optimized Blockwise NonLocal Means Denoising
    Filter for 3-D Magnetic Resonance Images", IEEE Trans. Med.
    Imaging, vol. 27, no. 4, pp. 425–441, 2008.
 
 
-----------------------------------------------------------------------
 Disclaimer
-----------------------------------------------------------------------

Any unauthorized use of these routines for industrial or profit-
oriented activities is expressively prohibited. By downloading 
and/or using any of these files, you implicitly agree to all the 
terms of the TUT limited license, as specified in the document
Legal_Notice.txt (included in this package) and online at
http://www.cs.tut.fi/~foi/GCF-BM3D/legal_notice.html


-----------------------------------------------------------------------
 Feedback
-----------------------------------------------------------------------

If you have any comment, suggestion, or question, please do
contact   Alessandro Foi  at  firstname.lastname@tut.fi


