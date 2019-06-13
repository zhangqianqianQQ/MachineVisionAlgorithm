# Face-Recognition-using-PCA
Implemented Principal Components Analysis algorithm in MATLAB for face recognition. Compared two faces by projecting the images into 
Eigenface space and measure the Euclidean distance between them

<h3>Main.m </h3>
Run whole program by runing this script.

<h3>ReadFace.m </h3>
Construct 2D matrix from all of the 1D image vectors in the training data file

<h3>EigenfaceCore.m </h3>
Compute the covariance matrix. Use the "svd" function to compute the eigenvectors and eigenvalues of the covariance matrix. Set Threshold 
value whatever you like to picks eigenvalues.

<h3>Recognition.m </h3>
Project the selected test image and all of the training images into Eigenfaces space. Compare the Euclidean distances between them and find the index of image who gets minmum Euclidean distances.

<h3>Visualize_Eigenface.m </h3>
Show the maxmum nine pictures of Eigenfaces.

<h3>Result </h3>
<p>Test Result 1</p>
<img src="/Result/Test Result 1.jpg" alt="Test Result 1" width="480" height="340">
<p>Test Result 2</p>
<img src="/Result/Test Result 2.jpg" alt="Test Result 2" width="480" height="340">
<p>Test Result 3</p>
<img src="/Result/Test Result 3.jpg" alt="Test Result 3" width="480" height="340">
<p>Eigenfaces</p>
<img src="/Result/Eigenfaces.jpg" alt="Eigenfaces" width="560" height="420">
