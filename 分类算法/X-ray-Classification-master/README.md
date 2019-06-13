# X-ray-Classification
Classify various radiology images into respective categories.Being done using various shape and texture features for feature extraction and SVM for classification. </br>
main_feature_extraction.m calculates the feature vector for a given category of images. A csv file is obtained containing the following feature vector of the images.  </br>
It uses the functions </br>
-> feature_vector.m  which computes the shape histogram and the </br>
-> density histogram from the function density_histogram.m      </br>
-> on various subblocks in an image which is computed from the function subblocks.m </br>
Every image is made of size 512x512 before extracting the features and in case of any dimension being less than 512, it is padded with zeros to make it 512x512 using padding.m. (No images have dimensions greater than 512). </br>
main_classification.m is used to do the classification on the obtained training and testing feature vectors using a </br>
-> one vs all svm obtained through the function multisvm.m which gives the accuracy_train as well as accuracy_test.
