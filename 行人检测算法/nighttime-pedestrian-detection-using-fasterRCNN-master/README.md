# Pedestrian detection based on faster R-CNN in nighttime by fusing deep convolutional features of successive images
By Jong Hyun Kim, Ganbayar Batchuluun, Kang Ryoung Park

<div align="left">
    <img src="/images/sample.jpg" width="800px"</img> 
</div>

### Introduction
This code is relative to [paper](https://www.sciencedirect.com/science/article/pii/S0957417418304354).

In the paper, training is done using Caltech and KAIST DB seperately, total 6 stages. However, this implementation trains network using both DB at the same time, total 4 stages, for simplicity, resulting a similar performance.

Also, this code is written based on the MATLAB implementations of [ShaoqingRen/faster_rcnn](https://github.com/ShaoqingRen/faster_rcnn) and [zhangliliang/RPN_BF](https://github.com/zhangliliang/RPN_BF).

This code has been tested on Windows7 with MATLAB 2017a.

### Requirements

0. Caffe

0. MATLAB

0. GPU: Geforce GTX 1070, etc

### Preparation for Training

0. download videos and toolboxes from [KAIST Multispectral Pedestrian Detection Benchmark](https://sites.google.com/site/pedestrianbenchmark/home) and [Caltech Pedestrian Detection Benchmark](http://www.vision.caltech.edu/Image_Datasets/CaltechPedestrians/).

0. extract visible camera images and annotations using each toolbox 

0. place KAIST(set00-05, skip=10), Caltech(set00-10, skip=30) training images and annotations in `./datasets/train/`

0. place KAIST(set06-11, skip=20) testing images and annotations in `./datasets/test/`

0. place the toolbox folders (KAIST, Caltech) in `./external/`, and name as `toolbox(kaist)` and `toolbox(caltech)`, respectively

0. run `fetch_data/fetch_caffe_mex_cuda65.m` to download a compiled Caffe mex (for Windows only).

0. download ImageNet-pre-trained VGG16(reduced for 7x3 ROI pooling) model(depicted below) from [GoogleDrive](https://drive.google.com/uc?export=download&id=1HIFDJtforADOt0M9P10AIUrY8qsA3MVc) and place it to `./models/pre_trained_models/vgg_16layers`

<div align="left">
    <img src="/images/fine_tuning.jpg" width="400px"</img> 
</div>

### Training

0. Run `startup.m`

0. Run `faster_rcnn_VGG16.m`

### Preparation for Testing

0. extract KAIST(set06-11) testing images with skip frame=1 for the fusion of successive images.

0. place these images in `./datasets/skip1/`

### Testing

0. Run `final_test.m` to get the result in `./test/faster-rcnn-test3`

0. Run `plotMR.m` to see the graph

