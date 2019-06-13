This is code to generate the bottom up segmentation, amodal completion,
semantic segmentation and scene classification results for our CVPR 13 paper,
Perceptual Organization and Recognition of Indoor Scenes from RGB-D Images. 
Saurabh Gupta, Pablo Arbelaez, Jitendra Malik, In CVPR 2013

Notes
-----

1. External Dependencies. Please put them in the folder external and modify
startup.m and COM/getPaths.m

  a. gPb-UCM, Contour and region benchmarking code from 
  http://www.eecs.berkeley.edu/Research/Projects/CS/vision/grouping/BSR/BSR_full.tgz 
  We modified the files match_segmentations2.m, ucm_mean_pb.cpp, buildW.cpp,
  and the patched files and patches are available in external/ 
  
  b. VLFeat from http://www.vlfeat.org/

  c. liblinear from http://www.csie.ntu.edu.tw/~cjlin/liblinear/, compile this
  to generate train.mex*, predict.mex*

  d. liblinear dense version from
  http://ttic.uchicago.edu/~smaji/projects/digits/, compile this to generate
  trainDense.mex* and predictDense.mex*

  e. SIFT color desprictors from http://www.colordescriptors.com, We used v2.1.

  f. Image Stack Library https://code.google.com/p/imagestack/, for computing
  the local deph boundary cues.

2. The code is intended for use with the data available here. This contains the
color images, preprocessed point clouds and the preprocessed ground truth. 
http://www.cs.berkeley.edu/~sgupta/cvpr13/data.tgz (please use wget if 
downloading in Chrome does not work). Please modify COM/getPaths.m 
and allBenchmarks/benchmarkPaths.m to point to where you put the data folder. 

3. We also provide the 
precomputed results, http://www.cs.berkeley.edu/~sgupta/cvpr13/output.tgz 
(please use wget if downloading in Chrome does not work), and the pretrained 
models, http://www.cs.berkeley.edu/~sgupta/cvpr13/model.tgz (please use 
wget if downloading in Chrome does not work).

Data Preprocessing
------------------
1. The data that we provide is different from the one provided by Silberman
etal in the following ways:
  
  a. We use I(46:470, 41:600, :) part of the image. This is different from what
  they use by 1 pixel on each side, I think.
  
  b. We use the original point clouds from the Kinect from over here
  http://horatio.cs.nyu.edu/mit/silberman/nyu_depth_v2/orig_images.mat, and
  project them to the RGB frame but instead of just keeping the Z coordinate
  also keep the X and the Y coordinate (keeping just the Z and projecting back
  rays to get X and Y introduces a little bit of error, but should still work
  well, we did not try using that...)

  c. Finally, we preprocessed the ground truth to get rid of the double
  contours.

Precomputed Results
-------------------
1. http://www.cs.berkeley.edu/~sgupta/cvpr13/output.tgz (please use wget if 
downloading in Chrome does not work):
includes the folder cachedir/release/output which contains the UCM, amodal
completion and the semantic segmentation outputs. Their are also .mat files
with the performance of our system.

Pre trained Models
------------------
1. http://www.cs.berkeley.edu/~sgupta/cvpr13/model.tgz (please use wget if 
downloading in Chrome does not work), includes the folder
cachedir/release/model which has the pretrained ucm models, various semantic
segmentation and scene classification models.


Questions and Comments
----------------------
Please feel free to email, sgupta at eecs dot berkeley dot edu for any questions and
comments.
