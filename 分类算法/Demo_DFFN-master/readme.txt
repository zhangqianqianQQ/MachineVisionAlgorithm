The code implementation of our TGRS paper "Hyperspectral Image Classification With Deep Feature Fusion Network"

If you use this code, please kindly cite our paper:
@article{song2018hyperspectral,
  title={Hyperspectral image classification with deep feature fusion network},
  author={Song, Weiwei and Li, Shutao and Fang, Leyuan and Lu, Ting},
  journal={IEEE Transactions on Geoscience and Remote Sensing},
  volume={56},
  number={6},
  pages={3173--3184},
  year={2018},
  publisher={IEEE}
}

This code is tested on the Ubuntu 16.04 system and caffe framework. Before running this code, you should correctly install ubuntu system and caffe framework. For caffe installation, you can refer to this guildeline "http://caffe.berkeleyvision.org/installation.html". Here, we assume the installation location of caffe is : ./Demo_DFFN/caffe-master. In addition, you should also  download the corresponding hyperspectral data sets and put them into folder "./Demo_DFFN/datasets/".

After correctly installing ubuntu and caffe, you can run this code by the following procedures. For the convenience, we take the Indian Pines image as a example. For the University of Pavia and Salinas images, please make some changes referring to codes. 
(1) Opening the matlab and changing the current path to the unzipped path,  running the "generating_data.m" to generate the training and       test samples, which are saved in the ./samples/indian_pines. Noteworthily, the format of samples is the hdf5 which is efficent for the     caffe input. Here, we have generated these samples for you;
(2) Opening the terminal and changing the current path to the unzipped path, then running this script:
    "sh train_DFFN.sh >& info/train_indian_pines.log". This script executes the training of DFFN and generate the corresponding training       log file;
(3) After training, running the following script to test network in the terminal same as (2):
    "sh test_DFFN.sh >& info/test_indian_pines.log". This script executes the test of DFFN and generate the corresponding test log file;
(4) running the "extract_prob.m" in matlab. This script is used to extract probability from the "test_indian_pines.log";
(5) running the "calculating_result.m" to calculate the matrics (OA, AA, Kappa, CA) and draw classification map.

If you have any questions, don't hesitate to contact me: Email: weiwei_song@hnu.edu.cn