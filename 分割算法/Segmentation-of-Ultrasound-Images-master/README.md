# Segmentation-of-Ultrasound-Images

## About This Project
The purpose of this study is the contour extraction of a region of interest in ultrasonic images. I applied the anisotropic diffusion algorithm to preprocess images, then an active contour model using a gradient vector flow was employed. In the end, the contour of a lesion area of the ultrasonic images were extracted.

--------------------Author by Yao Zhang

## MATLAB Function
* Main.m                     -click to run the whole problem
* AnisotropicDiffusion.m     -Used for smooth image preserving the edges in the image at same time.
* GVF.m                      -Compute the gradient vector flow.
* imdisp.m                   -scale the dynamic range of an image and display it.
* snakedeform.m              -In this function, the initial contour of Active Contour Model(Snake) will be deformed in the given external 
                             force field.
* snakedisp.m                -Display the snake model contour
* snakeindex.m               -Create index for adaptive interpolating the snake
* snakeinit.m                -Implement Canny Operator to initialize initial contour line for Active Contour Model
* snakeinterp.m              -interpolate the snake adaptively
## Result
### Preprocessed Images Result
So we can actually see that images noise are removed and the edges of object in the images are preserved.
![preprocessed image 1](https://cloud.githubusercontent.com/assets/11358094/24225295/1070872e-0f36-11e7-9151-07d87bf2a52e.JPG)
![preprocessed image 2](https://cloud.githubusercontent.com/assets/11358094/24225300/144647e4-0f36-11e7-8b7f-ef13679d83eb.JPG)

### Finial Result
There are initial contour line found by Canny Operator and corresponding final segmentation result.
1. First Example

![initial contour1_1](https://cloud.githubusercontent.com/assets/11358094/24225836/1218200c-0f39-11e7-9eb0-0100e090e3fe.JPG)
![initial contour1_2](https://cloud.githubusercontent.com/assets/11358094/24225839/1461d42a-0f39-11e7-9e52-923301a7dbe5.JPG)

* Final result

![final result 1](https://cloud.githubusercontent.com/assets/11358094/24225842/15aaee66-0f39-11e7-99fc-83e8e4ff6ed1.JPG)

2. Second Example

![initial contour2_1](https://cloud.githubusercontent.com/assets/11358094/24225866/4505724e-0f39-11e7-8268-b9060e43b0cb.JPG)
![initial contour2_2](https://cloud.githubusercontent.com/assets/11358094/24225867/469ea292-0f39-11e7-950d-b9a3e2c9f76f.JPG)

* Final result

![final result 2](https://cloud.githubusercontent.com/assets/11358094/24225869/498c8aaa-0f39-11e7-8cf3-ae14c18f06b5.JPG)

3. Third Example

![initial contour3_1](https://cloud.githubusercontent.com/assets/11358094/24225881/5f08b494-0f39-11e7-8baa-125dd6c02b32.JPG)
![initial contour3_2](https://cloud.githubusercontent.com/assets/11358094/24225884/600d9ee0-0f39-11e7-8971-c012f6ad0e42.JPG)

* Final result

![final result 3](https://cloud.githubusercontent.com/assets/11358094/24225885/611b17ae-0f39-11e7-84e9-0b0c1f00316b.JPG)

## Reference
* Perona P, Malik J. Scale-space and edge detection using anisotropic diffusion[J]. IEEE Transactions on pattern analysis and machine intelligence, 1990, 12(7): 629-639.
* Kass M, Witkin A, Terzopoulos D. Snakes: Active contour models[J]. International journal of computer vision, 1988, 1(4): 321-331.
* Yang-xu C. Snakes, shapes, and gradient vector flow[C]//Inter-national Conference on Image Processing. 2002, 9(2): 17-820.
* Gradient Vector Flow (GVF) Active Contour Toolbox by Chenyang Xu and Jerry Prince

