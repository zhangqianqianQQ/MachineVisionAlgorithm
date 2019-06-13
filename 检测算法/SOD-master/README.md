# Unconstrained Salient Object Detection

[![License](https://img.shields.io/packagist/l/doctrine/orm.svg)](LICENSE)

This is an implementation of the salient object detection method described in

> [Jianming Zhang, Stan Sclaroff, Zhe Lin, Xiaohui Shen, Brian Price and Radomír Mech. "Unconstrained Salient Object Detection via Proposal Subset Optimization." CVPR, 2016.](http://cs-people.bu.edu/jmzhang/sod.html)

This method aims at producing a highly compact set of detection windows for salient objects in uncontrained images, which may or may not contain salient objects. Please cite the above paper if you find this work useful.

## Prerequisites
1. Linux
2. Matlab 
3. Caffe & Matcaffe (**We use the official master branch downloaded on 4/1/2016. Previous versions may not be compatible.**)

## Quick Start
1. Unzip the files to a local folder (denoted as **root_folder**).
2. Enter the **root_folder** and modify the Matcaffe path in **setup.m**.
3. In Matlab, run **setup.m** and it will automatically download the pre-trained GoogleNet model.
4. Run **demo.m**.
 
## Evaluation
You can reproduce the result on [the MSO dataset](http://cs-people.bu.edu/jmzhang/sos.html) reported in the paper, by run **benchmarkMSO.m**. It will automatically download the MSO dataset and the pre-trained VGG16 model.

## Miscs
To change CNN models or other configurations, please check **getParam.m**.

In the demo, we use the pre-trained GoogleNet, which is faster and slightly better than the VGG16 model used in our paper.
We have also added a heuristic window refining process for small objects. 
Note that this process is not included in our paper or used in our evaluation.

