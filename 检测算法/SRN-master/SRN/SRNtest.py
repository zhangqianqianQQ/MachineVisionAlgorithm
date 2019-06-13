
'''
Created on Jan 27, 2016
for one model
@author: wke
'''

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.pylab as pylab
import matplotlib.cm as cm
import scipy.misc
from PIL import Image
import scipy.io as scio
import os
from pylab import * # for showing
from termios import VMIN
import datetime

caffe_root = '../../'
import sys
sys.path.insert(0, caffe_root + 'python')
import caffe


data_root = '../../data/datasets_original/SymPASCAL/'
with open(data_root+'test.lst') as f:
    test_lst = f.readlines()
test_lst = [data_root+'/images/test/'+x.strip()+'.jpg' for x in test_lst]
  
im_lst = []
for i in range(0, len(test_lst)):
    im = Image.open(test_lst[i])
    in_ = np.array(im, dtype=np.float32)
    in_ = in_[:,:,::-1]
    in_ -= np.array((104.00698793,116.66876762,122.67891434))
    im_lst.append(in_)
    
#Visualization
def plot_single_scale(scale_lst, size):
    pylab.rcParams['figure.figsize'] = size, size/2
    
    plt.figure()
    for i in range(0, len(scale_lst)):
        s=plt.subplot(1,5,i+1)
        plt.imshow(1-scale_lst[i], cmap = cm.Greys_r)
        #plt.imshow(1-scale_lst[i])
        s.set_xticklabels([])
        s.set_yticklabels([])
        s.yaxis.set_ticks_position('none')
        s.xaxis.set_ticks_position('none')
    plt.tight_layout()


idx = 18

in_ = im_lst[idx]
in_ = in_.transpose((2,0,1))
#remove the following two lines if testing with cpu
caffe.set_mode_gpu()
caffe.set_device(0)

# load net
model_root = './'
net = caffe.Net(model_root+'deploy.prototxt', model_root+'san_iter_18000.caffemodel', caffe.TEST)

net.blobs['data'].reshape(1, *in_.shape)
net.blobs['data'].data[...] = in_
net.forward()
#out1 = net.blobs['sigmoid-dsn1'].data[0][0,:,:]
out2 = net.blobs['sigmoid-dsn2'].data[0][0,:,:]
out3 = net.blobs['sigmoid-dsn3'].data[0][0,:,:]
out4 = net.blobs['sigmoid-dsn4'].data[0][0,:,:]
out5 = net.blobs['sigmoid-dsn5'].data[0][0,:,:]
fuse = net.blobs['sigmoid-fuse'].data[0][0,:,:]


scale_lst = [fuse]
plot_single_scale(scale_lst, 22)
scale_lst = [out2, out3, out4, out5]
plot_single_scale(scale_lst, 10)
show()


starttime = datetime.datetime.now()      
for iidx in range(0, len(test_lst)):
    print(iidx)
    in_ = im_lst[iidx]
    in_ = in_.transpose((2,0,1))
    net.blobs['data'].reshape(1, *in_.shape)
    net.blobs['data'].data[...] = in_
    net.forward()
    fuse = net.blobs['sigmoid-fuse'].data[0][0,:,:]

endtime = datetime.datetime.now()
interval=(endtime - starttime).seconds
print interval
