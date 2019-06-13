Part-based RCNNs for Fine-grained Category Detection
===============
This work is created by Ning Zhang, Jeff Donahue, Ross Girshick and Trevor Darrell from UC Berkeley. 


### Citing this work
If you are using this code for your research, please cite the following paper:

    @inproceedings{ZhangECCV14,
        Author = {Zhang, Ning and Donahue, Jeff and Girshick, Ross and Darrell, Trevor},
        Title = {Part-based RCNN for Fine-grained Detection},
        Booktitle = {European Conference on Computer Vision},
        Year = {2014}
    }

### License
This software is under BSD 3-Clause License, please refer to LICENSE file.

### Prerequisites
0. **Caffe**
 - Download caffe from http://caffe.berkeleyvision.org/ and follow the instructions to install. 
 - Change caffe matlab wrapper path in init.m

0. **RCNN**
  - Download source code from https://github.com/rbgirshick/rcnn and follow the instructions to install.  
  - Change rcnn path in init.m
  - In order to train part detectors for CUB2011 dataset, replace the following three functions in imdb/imdb_from_voc.m imdb/roidb_from_voc.m and imdb/imdb_eval_voc.m to the functions in imdb_cub folder.
  - Follow rcnn instructions to train the part detectors.

0. **Liblinear**
  - Download liblinear package from http://www.csie.ntu.edu.tw/~cjlin/liblinear/

Annotation/ has annotated part boxes on CUB200-2011 dataset.

### Usage
  - run.m is the main function to reproduce the results in the paper. 
  - Part detectors, finetuned models, feature representations are cached. Download the cache files by running get_cache_files.sh and unzip to caches/ folder.

###Bug report
If you have any issues running the codes, please contact Ning Zhang (nzhang@eecs.berkeley.edu).
