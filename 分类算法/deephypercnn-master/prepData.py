# -*- coding: utf-8 -*-
"""
Created on Mon Oct 10 23:58:35 2016

@author: Subhajit
"""


import numpy as np
import scipy.io
import h5py

def load_matfile(filename='./data/indian_pines_data.mat'):
    f = h5py.File(filename)
    #print f['X_r'].shape
    if 'pca' in filename:
        X=np.asarray(f['X_r'],dtype='float32')
    else:
        X=np.asarray(f['X'],dtype='float32')
    y=np.asarray(f['labels'],dtype='uint8')
    gt=np.asarray(f['ip_gt'],dtype='uint8')
    #im=np.asarray(f['im'],dtype='uint8')
    f.close()
    
    X=X.transpose(3,2,1,0)
    y=np.squeeze(y)-1
    gt=gt.transpose(1,0)
    #im=im.transpose(2,1,0)
    return X,y,gt
    


if __name__=='__main__':
    X,y,gt,im=load_matfile(filename='./data/Indian_pines_pca.mat')
    