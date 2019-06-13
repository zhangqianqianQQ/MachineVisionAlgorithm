---------------
Part 1
------
This is pedestrian detection using SVM classifier.
To use it, first decide which image you want to detect. Images are under "testimgs" folder. 

For example, if you want to detect the humans in "soccer.JPG". Type the following command in MATLAB:

pedestrian_detection(false, 'soccor.JPG');

It loads the trained model from file "model_svm.mat" and detect human in this image. The first argument is set to true when training this model. Since we don't have enough space to upload our training dataset, don't set it to true unless you have our training dataset.

Here is a list of the testimg filenames:


	profile_human_test_178.bmp
	profile_human_test_189.bmp
	sidewalk_242.bmp
	soccor.JPG
	soccor-crop.jpg
	walkingpeople_266.bmp
	walkingpeople_594.bmp

---------------
---------------
Part 2
------

Another implementation in this folder is our own version of HoG feature extractor. 

To use it, try the sample call. The first argument specifies the name of image. Set the second argument to true to enable visualization:

feature = hog_hiker('soccor-crop.jpg', true);
---------------
