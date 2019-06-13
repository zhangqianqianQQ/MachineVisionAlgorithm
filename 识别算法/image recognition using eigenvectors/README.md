# ImageRecognition

This Project implements Eigenfaces for Recognition as described by M. Turk and A. Pentland in Journal of Cognitive Neuroscience, 3(1), 1991 

The Project had two phases:
1. Building the eigenspace from the forty images given. Determine a reasonably low-dimension to project onto by looking at the eigenvalues of the covariance matrix. Store the new low-dimensional representation of each of the 40 training images.

2. Given an image, project this image onto the new low-dimensional space, and find the closest match from the training set constructed above. Test the recognition on the original forty training images as well as forty test images.

Then evaluate the accuracy of the face recognition for both the training and testing stages.


The Code:

Use imagevectormatrix.m to convert your images to 1D vectors of data.

Then create eigenfaces using eigenfaces.m along with a mean image and the deviations.

Use Recognition to query the database for a test image.



Results.pdf contains the observations made and the conclusions drawn.