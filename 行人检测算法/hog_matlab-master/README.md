# hog_matlab
Matlab implementation of the HOG person detector. 

Some things you should know going into this:

* The HOG detector is compute intense, and this is *not* a highly-optimized implementation.
* The primary value in this code, I think, is to use it to learn about the HOG detector. 
  * The code is well documented, and Matlab syntax makes the operations fairly plain.
  * It will be much easier to learn about the details of the detector from this code, I think, than from the optimized OpenCV implementation, for example.

**HOG Tutorial**

For a tutorial on the HOG descriptor, check out my [HOG tutorial post](http://mccormickml.com/2013/05/09/hog-person-detector-tutorial/).

**Key Source Files**

* `runSingleWindowExample.m` - Calculates the HOG descriptor for a single image that has been cropped down to the detector size. Look at this for learning about the descriptor by itself (without all of the complexities added by actually searching a full image for persons). It leverages the following two functions, which, along with my [tutorial](http://mccormickml.com/2013/05/09/hog-person-detector-tutorial/), are a good way to learn how the descriptor works.
  * `getHOGDescriptor.m` - Calculates the HOG descriptor for a given detection window.
  * `getHistogram.m` - Calculates the histogram for a single image cell.
* `trainDetector.m` - Trains a linear SVM on the ~2.2k pre-cropped windows in the `/Images/Training/` folder. There is also already a pre-trained model saved in `hog_model.mat`, so you don't have to run this function in order to play with the examples.
* `runSearchExample.m` - Applies a pre-trained HOG detector to a sample validation image, reports the detector accuracy, and displays the image with true positives drawn.

The project also includes the following subdirectories:
* The `search` folder contains functions specifically related to searching an image for persons.
* The `graphics` folder just contains a function for resizing images, and another for plotting detection rectangles.
* The `Images` folder contains sample training and validation images.
* The `svm` folder contains everything needed to train a linear SVM.

**Result Clustering**

On the image search side, one of the most important things missing here is result clustering. I wrote a [blog post](http://mccormickml.com/2013/11/07/opencv-hog-detector-result-clustering/) on the OpenCV implementation of result clustering, but I haven't taken the time to port any of this over to Matlab yet.  

**Differences with OpenCV Implementation**

The HOG descriptor implemented here is very similar to the original implementation and the one in OpenCV, but there are a few differences:	
* OpenCV uses L2 hysteresis for the block normalization.
* OpenCV weights each pixel in a block with a Gaussian distribution before normalizing the block.
* The sequence of values produced by OpenCV does not match the order of the values produced by this code.

The image search functionality differs in many ways from the OpenCV implementation.

**Order of Values**

You may not need to understand the order of bytes in the final vector in order to work with it, but if you're curious, here's a description.

The values in the final vector are grouped according to their block. A block consists of 36 values: 1 block  *  4 cells / block  * 1 histogram / cell * 9 values / histogram = 36 values / block.

The first 36 values in the vector come from the block in the top left corner of the detection window, and the last 36 values in the vector come from the block in the bottom right.

Before unwinding the values to a vector, each block is represented as a 3D dimensional matrix, 2x2x9, corresponding to the four cells in a block with their histogram values in the third dimension. To unwind this matrix into a vector, I use the colon operator ':', e.g., A(:).  You can reshape the values into a 3D matrix using the 'reshape' command. For example:

```matlab
% Get the top left block from the descriptor.
block1 = H(1:36);

% Reshape the values into a 2x2x9 matrix B1.
B1 = reshape(block1, 2, 2, 9);
```

