# segDeepM
Object detection with segmentation and context in deep networks.

# Usage

1. Following https://github.com/rbgirshick/rcnn to set up caffe and RCNN;

2. Fine-tune VGG/AlexNet and put the models to data/caffe_nets/ (finetuned model also available at http://www.cs.toronto.edu/~yukun/segdeepm.html)

3. Put pre-computed CPMC masks and corresponding potentials to segDeepM/ and run segDeepM.m;

4. Enjoy :)

# citing segDeepM

Please consider citing our segDeepM paper and the original RCNN paper if you use this code for your research. 

    @inproceedings{ZhuSegDeepM15,
    title = {segDeepM: Exploiting Segmentation and Context in Deep Neural Networks for Object Detection},
    author = {Yukun Zhu and Raquel Urtasun and Ruslan Salakhutdinov and Sanja Fidler},
    booktitle = {CVPR},
    year = {2015}
    }

    @inproceedings{girshick14CVPR,
        Author = {Girshick, Ross and Donahue, Jeff and Darrell, Trevor and Malik, Jitendra},
        Title = {Rich feature hierarchies for accurate object detection and semantic segmentation},
        Booktitle = {Computer Vision and Pattern Recognition},
        Year = {2014}
    }
