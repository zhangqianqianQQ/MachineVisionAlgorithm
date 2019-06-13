# DAIN

[[Arxiv]](https://arxiv.org/abs/1612.02372) [[Project]](http://eceweb1.rutgers.edu/vision/gts/gtos.html)

This repository contains the code for our CVPR 2017 paper:

    Jia Xue, Hang Zhang, Kristin Dana, Ko Nishino
    "Differential Angular Imaging for Material Recognition"
    in Proc. CVPR 2017

## Setup

### Prerequisites

- Ubuntu 14.04
- NVIDIA GPU + CUDA CuDNN

### Getting Started

- Clone this repo:
```bash
git clone git@github.com:mrxue1993/DAIN.git
cd DAIN
```
- Compile the code by running ```compile.m```
- Run ```runExperiment.m```

## Pretrained models

## Datasets
You can find the database [here](http://jiaxueweb.com/)
## Acknowledgement

The code is heavily based on the [twostreamfusion](https://github.com/feichtenhofer/twostreamfusion), it only supports single GPU, if you meet problem to run the code, please check [here](https://github.com/feichtenhofer/twostreamfusion/issues).

This work was supported by National Science Foundation award IIS-1421134. A GPU used for this research was donated by the NVIDIA Corporation. Thanks to Di Zhu, Hansi Liu, Lingyi Xu, and Yueyang Chen for help with data collection.
