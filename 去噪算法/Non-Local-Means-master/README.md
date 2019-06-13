# Non local Means

## Intro

In this project I implemented a non-local mean filtering in a naive way and using integral images. These two methods 
are both explained in the papers : 

1. Non-Local Means Denoising
2. Integral Images for Block Matching

## Description

The non local-means algorithm is used to remove noise from an image. We have in input three things: 
1. The image we want to denoise  
2. A kernel of size k x k
3. A window of size w x w

![Alt text](./alleyNoisy_sigma20_copy.png?raw=true "Example")


for each pixel in the image (that we are going to denoise) we center the window around it, usually the window is reasonably big but of course not as big as the entire image for performance reasons.
Then for each pixel in the window we slide a patch (usually 3x3 or 5x5) and the pixel that we want to denoise will be a weighted sum over the patches of the images.

### Integral images improvement 

If we make use of integral images we can speed up computations.

#### Image taken from Prof. Lourdes Agapito slides in the image processing course at University College London
![Alt text](./integralImages.png?raw=true "Example")

We can speed up computations because of the formula :
#### Image taken from Wikipedia (https://en.wikipedia.org/wiki/Summed-area_table#/media/File:Summed_area_table.png)

![Alt text](./Summed_area_table.png?raw=true "Example")

## How to use the code  

Just open Matlab and run the nonLocalMeans.m file for the integral images implemenatation and the nonLocalMeansWithoutIntegral.m for the naive version. Note that without the boost provided by the integral images the naive version will be quite slow :) .
