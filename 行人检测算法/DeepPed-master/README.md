## DeepPed: *Deep Convolutional Neural Networks for Pedestrian Detection*

Created by Denis Tomè, Federico Monti, Luca Baroffio and Luca Bondi.

### Introduction

DeepPed is a state-of-the-art pedestrian detector that extends R-CNN work done by Girshick et al. combining region proposals with rich features computed by a convolutional neural network. This method achieves 19.90% log-average-miss-rate on the Caltech Pedestrian Dataset.

DeepPed is described in an [arXiv tech report](http://arxiv.org/abs/1510.03608) and will appear in Elsevier Journal of Signal Processing.

### Citing R-CNN

If you find R-CNN useful in your research, please consider citing:

    @article{tome2015Deep,
        author = {Tomè, Denis and Monti, Federico and Baroffio, Luca and Bondi, Luca and Tagliasacchi, Marco and Tubaro, Stefano},
        title = {Deep convolutional neural networks for pedestrian detection},
        journal = {arXiv preprint arXiv:1510.03608},
        year = {2015}
    }
}

### License

DeepPed is released under the Simplified BSD License (refer to the
LICENSE file for details).

### Installing R-CNN

0. **Prerequisites** 
  0. MATLAB (tested with 2015a on 64-bit Linux)
  0. Caffe's [prerequisites](http://caffe.berkeleyvision.org/installation.html#prequequisites)
0. **Install Caffe and R-CNN**
  0. Download [Caffe](https://github.com/BVLC/caffe) (version described in R-CNN instructions)
  0. Download R-CNN and follow the [instructions](http://github.com/rbgirshick/rcnn)
0. **Install DeepPed**
  0. Change into the R-CNN source code directory: `cd rcnn`
  0. Get the DeepPed source code by cloning the repository: `git clone https://github.com/DenisTome/DeepPed.git`
  0. Get the Piotr's Image & Video Matlab Toolbox by cloning the repository: `git clone https://github.com/pdollar/toolbox.git`
  0. From the `R-CNN` folder, run the model fetch script: `./DeepPed/fetch_models.sh`. 
  0. Open the `startup.m` matlab file, adding the two commands `addpath(genpath('DeepPed'));` and `addpath(genpath('toolbox'));` at the end of the file.

### Running DeepPed on an image

1. Change to where you installed R-CNN: `cd rcnn`. 
2. Start MATLAB `matlab`.
  * **Important:** if you don't see the message `R-CNN startup done` when MATLAB starts, then you probably didn't start MATLAB in `rcnn` directory.
3. Run the demo: `>> deepPed_demo`
