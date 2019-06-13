# -*- coding: utf-8 -*-
"""
Created on Sat Mar 12 15:08:58 2016

@author: priyanka
"""

import glob
from PIL import Image
import numpy as np
import cv2
from matplotlib import pyplot as plt


def resizeAndSaveImage(img,path,fileName):
    resize_val=227
    height,width,d=img.shape
    if width>height:
        res=(height*resize_val)/width
        resized=cv2.resize(img,(resize_val,res))
        rep=(resize_val-res)/2
        replicate = cv2.copyMakeBorder(resized,rep,rep,0,0,cv2.BORDER_REPLICATE)
    else:
        res=(width*resize_val)/height
        resized=cv2.resize(img,(res,resize_val))
        rep=(resize_val-res)/2
        replicate = cv2.copyMakeBorder(resized,0,0,rep,rep,cv2.BORDER_REPLICATE)
    img = Image.fromarray(replicate.astype('uint8'))
    img.save(path+""+fileName)
    #plt.imshow(img),plt.show()    
    
def r_lookup(x):
    x=x/255.0
    r_val=0
    if x <= (0.5):
        r_val = ((-2*x)+1)
    return 255.0*r_val
    
def g_lookup(x):
    x=x/255.0
    g_val=0
    if x>=(0.5) and x<= (0.75):
        g_val=-(4*x)+3
    elif x > (0.25) and x <= (0.5):
        g_val= (4*x)-1
    return 255.0*g_val
     

def b_lookup(x):
    x=x/255.0
    b_val=0
    if x >= (0.5):
        b_val=((2*x)-1)
    return 255.0*b_val

def pre_process_depth(depth_img):
    total_img_arr=np.zeros((depth_img.shape[0],depth_img.shape[1],3))
    depth_img=depth_img.astype(float)
    depth_img=np.subtract(depth_img,np.min(depth_img[np.nonzero(depth_img)]))
    depth_img *= 255/depth_img.max()
    
    for i in range(depth_img.shape[0]):
        for j in range(depth_img.shape[1]):
            if (depth_img[i,j] <0.0) :
               depth_img[i,j] = 0.0   
            new_r=r_lookup(np.float(depth_img[i,j]))
            new_g=g_lookup(np.float(depth_img[i,j]))
            new_b=b_lookup(np.float(depth_img[i,j]))
            total_img_arr[i,j]= [new_r,new_g,new_b]    
    total_img = Image.fromarray(total_img_arr.astype('uint8'))
    #plt.imshow(total_img),plt.show() 
    return total_img_arr


def preprocess(ptr):
    with open(ptr) as testFilePtr:
        lines = testFilePtr.readlines()
        for line in lines:
            rgbfileName=line[0:-2].strip()
            depthfileName=line[0:-11].strip()+"depthcrop.png"
            rgbImageArray = np.array(Image.open("rgb/"+rgbfileName))
            depthImageArray = np.array(Image.open("depth/"+depthfileName))
            print rgbfileName
            resizeAndSaveImage(rgbImageArray,'p_rgb/',rgbfileName)
            clr_depth_img=pre_process_depth(depthImageArray)
            resizeAndSaveImage(clr_depth_img,'p_depth/',depthfileName)
            
train_writefp="train_annot.txt"
test_writefp ="val_annot.txt"
preprocess(test_writefp)
preprocess(train_writefp)