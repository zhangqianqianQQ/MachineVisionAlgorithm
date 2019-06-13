# SSD-Single-Shot-Detector-in-Matlab
SSD for object detection in matlab. SSD网络用于目标检测（Matlab版）。


1 Introduction（简介）

  This project provide a forward propagate demo of SSD(Singgle Shot Detector) network in matlab. SSD is a CNN(convolutional neraul network) architecture for object detection. We download the pretriand caffemodel VGG_VOC0712_SSD_300x300_iter_240000.caffemodel, and then convert it to .mat file for object detection. The codes of layers in SSD is written by author. No deep learning freamwork is needed. 
  
  该程序可用于SSD的Matlab目标检测。SSD是一种用于目标检测的CNN架构。我们将训练好的caffemodel（VGG_VOC0712_SSD_300x300_iter_240000.caffemodel）转成.mat文件用于目标检测。SSD中各层的函数有作者编写，不需要额外的深度学习开源框架。
  
  
2 How to Run This Demo（程序运行）

  (1) Open SSD_Emulation_Script.m.   打开SSD_Emulation_Script.m文件。
  (2) unzip ssd_weights_mat.zip to ssd_weights_mat folder.  解压ssd_weights_mat.zip到ssd_weights_mat。
  (3) Change the directory of image file on your computer (line 24: Img_Path = 'pedestrian2.jpg';).
      更改图像路径。（第24行：Img_Path = 'pedestrian2.jpg';）
      
3 Basic layers in CNN

  (1) conv
  Input(输入)：
    in_array		-----> Input feature map.(dim = 3, height, width, channels) 输入特征图，维度为3（高、宽、深或原始图像的通道数）。
    kernels			-----> Convolution kernel.(dim = 4, height, width, channels, kernel number) 卷积核，维度为4（高、宽、深、卷积核个数）。
    stride			-----> Stride.  卷积核移动步长。
    padding			-----> Padding. 填充像素数。
    dilation    -----> Dialation. 卷积核膨胀距离。
  output(输出)：
    out_array   -----> Output feature map.(dim = 3, height, width, channels)  输出特征图，维度为3（高、宽、深）。
  
  (2) relu 
  Input(输入)：
    in_array    	-----> Input feature map.(dim = 3, height, width, channels) 输入特征图，维度为3（长、宽、深）。
  Output(输出)：
    out_array   	-----> Output feature map.(dim = 3, height, width, channels)  输出特征图，维度为3（长、宽、深）。
    
  (3) pooling
  Input(输入)：
    in_array    	-----> Input feature map.(dim = 3, height, width, channels) 输入特征图（dim = 3）。
    window_size 	-----> Size of window.  池化窗口大小。
    stride      	-----> Stride.  步长。
    padding     	-----> Padding. 填充像素数。
  Output(输出)：
    out_array   	-----> Output feature map.(dim = 3, height, width, channels)  输出特征图（dim = 3）。
    
  (4) prior box generation
  Input(输入)：
    scale           	-----> Scale for detection used feature maps. 特征图对应尺度。
    aspect_ratio    	-----> Aspect ratio for detection used feature maps.特征图Box对应长宽比。
    feature_size    	-----> Size for detection used feature maps.特征图大小。
  Output(输出)：
    priorbox        	-----> Prior box. 输出Prior Box。
    
Detail information can be found in pdf. (only chinese version)
    
