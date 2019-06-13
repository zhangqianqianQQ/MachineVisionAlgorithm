## *Object detection via a multi-region & semantic segmentation-aware CNN model*

### Introduction:

This code implements the following ICCV2015 accepted paper:  
**Title:**            "Object detection via a multi-region & semantic segmentation-aware CNN model"  
**Authors:**          Spyros Gidaris, Nikos Komodakis  
**Institution:**      Universite Paris Est, Ecole des Ponts ParisTech  
**Technical report:** http://arxiv.org/abs/1505.01749  
**Code:**             https://github.com/gidariss/mrcnn-object-detection  

**Abstract:**  
"We propose an object detection system that relies on a multi-region deep convolutional neural network (CNN) that also encodes semantic segmentation-aware features. The resulting CNN-based representation aims at capturing a diverse set of discriminative appearance factors and exhibits localization sensitivity that is essential for accurate object localization. We exploit the above properties of our recognition module by integrating it on an iterative localization mechanism that alternates between scoring a box proposal and refining its location with a deep CNN regression model. Thanks to the efficient use of our modules, we detect objects with very high localization accuracy. On the detection challenges of PASCAL VOC2007 and PASCAL VOC2012 we achieve mAP of 78.2% and 73.9% correspondingly, surpassing any other published work by a significant margin."   

If you find this code useful in your research, please consider citing:  

> @inproceedings{gidaris2015object,  
  title={Object Detection via a Multi-Region and Semantic Segmentation-Aware CNN Model},  
  author={Gidaris, Spyros and Komodakis, Nikos},  
  booktitle={Proceedings of the IEEE International Conference on Computer Vision},  
  pages={1134--1142},  
  year={2015}}  

### License:
This code is released under the MIT License (refer to the LICENSE file for details).  

### Requirements:

Software:  
1. MATLAB (tested with R2014b)  
2. Caffe: https://github.com/BVLC/caffe  (built with CuDNN)  
3. LIBLINEAR (only for training)    
4. Edge Boxes code: https://github.com/pdollar/edges  
5. Piotr's image processing MATLAB toolbox: http://vision.ucsd.edu/~pdollar/toolbox/doc/index.html  
6. Selective search code: http://huppelen.nl/publications/SelectiveSearchCodeIJCV.zip  

Data:   
1. PASCAL VOC2007 detection data: http://host.robots.ox.ac.uk/pascal/VOC/    
2. PASCAL VOC2012 detection data: http://host.robots.ox.ac.uk/pascal/VOC/  

### Installation:

1. Install CAFFE https://github.com/BVLC/caffe  (with CuDNN)  
2. Place a soft link of caffe installation directory on `{path-to-mrcnn-object-detection}/external/caffe` 
3. Place a soft link of the edge boxes installation directory on `{path-to-mrcnn-object-detection}/external/edges`
4. Downlaod the archive file https://drive.google.com/file/d/0BwxkAdGoNzNTaVl3ZF9CYndIbFE/view?usp=sharing and then   unzip and untar it in the following location: 
	`{path-to-mrcnn-object-detection}/data/vgg_pretrained_models`
It contains:
    1. the VGG16-Net pre-trained on ImageNet model (weights + definition files)   
    2. the Semantic Segmentation Awarce activations maps module (see section 4 of technical report) pre-trained on VOC2007 (weights + defintion files)  
    3. some other necessary configuration files  
5.  open matlab from the directory `{path-to-mrcnn-object-detection}/`
6.  Edit the `startup.m` script by setting the installation directory paths of 1) Edge Boxes, 2) Piotr's image processing MATLAB toolbox, and 3) Selective Search to the proper variables (see `startup.m`). After having set the paths run the `startup.m` script from matlab command line  
8.  Run the `mrcnn_build.m` script on matlab command line

To run experiments on PASCAL VOC2007 or/and PASCAL VOC2012 datasets you need to:

1. Place the VOCdevkit of VOC2007 on `{path-to-mrcnn-object-detection}/datasets/VOC2007/VOCdevkit` and its data on `{path-to-mrcnn-object-detection}/datasets/VOC2007/VOCdevkit/VOC2007` 
2. Place the VOCdevkit of VOC2012 on `{path-to-mrcnn-object-detection}/datasets/VOC2012/VOCdevkit` and its data on `{path-to-mrcnn-object-detection}/datasets/VOC2012/VOCdevkit/VOC2012`

### Download and use the pre-trained object detection models

1. Multi-region CNN recognition model (section 3 of the technical report). Dowload the archive file of the model from https://drive.google.com/file/d/0BwxkAdGoNzNTaTNQR3pJcVU4WDg/view?usp=sharing and then untar and unzip it on the following location:  
    `{path-to-mrcnn-object-detection}/models-exps/MRCNN_VOC2007_2012`  
2. Multi-region with the semantic segmentation aware features CNN recognition model (sections 3 & 4 of the technical report). Dowload the archive file of the model from https://drive.google.com/file/d/0BwxkAdGoNzNTNVRrZzdlMEtLMjA/view?usp=sharing and then untar and unzip it on the following location:  
    `{path-to-mrcnn-object-detection}/models-exps/MRCNN_SEMANTIC_FEATURES_VOC2007_2012`  
The above directory does not contain the weight files of the multi-region cnn model. Copy them from `{path-to-mrcnn-object-detection}/models-exps/MRCNN_VOC2007_2012` by running on linux command line:  
`cp {path-to-mrcnn-object-detection}/models-exps/MRCNN_VOC2007_2012/*.caffemodel {path-to-mrcnn-object-detection}/models-exps/MRCNN_SEMANTIC_FEATURES_VOC2007_2012/`
3. CNN-based bounding box regression model (section 5 of the technical report).  Dowload the archive file of the model from https://drive.google.com/file/d/0BwxkAdGoNzNTTWtvZTRNMWtwemM/view?usp=sharing and then untar and unzip it on the following location:  
    `{path-to-mrcnn-object-detection}/models-exps/vgg_bbox_regression_R0013_voc2012_2007`

All of the above models were trained on the union of VOC2007 train+val plus VOC2012 train+val datasets

### Demos:
1. `"{path-to-mrcnn-object-detection}/code/example/demo_MRCNN_detection.m"`  
It detects objects in an image using the multi-region CNN recognition model (section 3 of the technical report). For this demo the semantic segmentation aware features and the iterative localization scheme are not being used.
2. `"{path-to-mrcnn-object-detection}/code/example/demo_MRCNN_with_Iterative_Localization.m"`  
It detects objects in an image using the multi-region CNN recognition model (section 3 of the technical report) and the iterative localization scheme (section 5 of the technical report). For this demo the semantic segmentation aware features are not being used.
3. `"{path-to-mrcnn-object-detection}/code/example/demo_MRCNN_with_SCNN_detection.m"`  
It detects objects in an image using the multi-region with the semantic segmentation-aware CNN features recognition model (sections 3 and 4 of the technical report). For this demo the iterative localization scheme is not being used.
4. `"{path-to-mrcnn-object-detection}/code/example/demo_MRCNN_with_SCNN_and_Iterative_Localization.m"`  
It detects objects in an image using the multi-region with the semantic segmentation-aware CNN features recognition model (sections 3 and 4 of the technical report) and the iterative localization scheme (section 5 of the technical report). 

To run the above demos you will require a GPU with at least 12 Gbytes of memory

### Testing the pre-trained models on VOC2007 test set:

1. Test the multi-region CNN recognition model coupled with the iterative bounding box localization module on the VOC2007 test set by running:  
	+ `script_extract_vgg16_conv_features('test', '2007', 'gpu_id', 1);`  
	It pre-caches the VGG16 conv5 feature maps for the scales 480, 576, 688, 874, and 1200 (see activation maps in section 3 of the technical report). The gpu_id parameter is the one-based index of the GPU that will be used for running the experiments. If a non positive value is given then the CPU will be used instead.  
	+ `script_test_object_detection_iter_loc('MRCNN_VOC2007_2012', 'vgg_bbox_regression_R0013_voc2012_2007', 'gpu_id', 1, 'image_set_test', 'test', 'voc_year_test','2007');`  
	It applies the detection pipeline on the images of VOC2007 test set. By default, this script uses the edge box proposals as input to the detection pipeline.   

2. Test the multi-region with the semantic segmentation aware cnn features recognition model coupled with the iterative bounding box localization module on the VOC2007 test set by running:   
	+ `script_extract_vgg16_conv_features('test', '2007', 'gpu_id', 1);`  
	It pre-caches the VGG16 conv5 feature maps for the scales 480, 576, 688, 874, and 1200 (see activation maps in section 3 of the technical report).
	+ `script_extract_sem_seg_aware_features('test', '2007', 'gpu_id', 1);`  
	It pre-caches the semantic segmentation aware activation maps for the scales 576, 874, and 1200 (see section 4 of the technical report). 
	+ `script_test_object_detection_iter_loc('MRCNN_SEMANTIC_FEATURES_VOC2007_2012','vgg_bbox_regression_R0013_voc2012_2007', 'gpu_id', 1, 'image_set_test', 'test', 'voc_year_test','2007');`  
	It applies the detection pipeline on the images of VOC2007 test set. By default, this script uses the edge box proposals as input to the detection pipeline.
 
To run the above scripts you will require a GPU with at least 6 Gbytes of memory

### Train the recognicion/regression models on PASCAL VOC 

See the script `{path-to-mrcnn-object-detection}/code/script_train_cnn_recognition_regression_models.m`  

