drfi_matlab
===========

MATLAB implementation of the paper Salient Object Detection: A Discriminative Regional Feature Integration Approach

This implementation contains the full pipiline of the approach, including both the training and testing phases. Run compile.m to compile the mex files. 

Before testing, you might want to download our pre-trained Random Forest model, which is available at http://jianghz.me/drfi/files/drfiModelMatlab.zip. Put it into the model folder.

If you want to train your own Random Forest regressor, check the trainAll.m for instructions. For more details, check out our technical report http://arxiv.org/pdf/1410.5926v1.

Tested on Windows 7 64bit with MATLAB 2012b and Ubuntu 12.04 64bit with MATLAB 2012a.

Bugs, comments are welcome to hzjiang@cs.umass.edu.
