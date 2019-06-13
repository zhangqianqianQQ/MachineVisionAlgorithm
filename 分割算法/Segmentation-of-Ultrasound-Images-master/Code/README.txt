# Segmentation-of-Ultrasound-Images


## About This Project
The purpose of this study is a contour extraction of a region
of interest in ultrasonic images. An active contour model using a gradient 
vector 
flow was employed. The contour of a lesion area of the ultrasonic images which 
speckle are reduced was extracted.



--------------------Author by Yao Zhang



## MATLAB Function

* Main.m                     -click to run the whole problem

* AnisotropicDiffusion.m     -Used for smooth image preserving the edges in the 
                              image at same time.

* GVF.m                      -Compute the gradient vector flow.

* imdisp.m                   -scale the dynamic range of an image and display it.

* snakedeform.m              -In this function, the initial contour of Active 
                              Contour Model(Snake) will be deformed in the given 
                              external force field.

* snakedisp.m                -Display the snake model contour

* snakeindex.m               -Create index for adaptive interpolating the snake
.
* snakeinit.m                -Implement Canny Operator to initialize initial 
                              contour line for Active Contour Model

* snakeinterp.m              -interpolate the snake adaptively




## Reference
* Perona P, Malik J. Scale-space and edge detection using anisotropic diffusion[J]. IEEE Transactions on pattern analysis and machine intelligence, 1990, 12(7): 629-639.

* Kass M, Witkin A, Terzopoulos D. Snakes: Active contour models[J]. International journal of computer vision, 1988, 1(4): 321-331.

* Yang-xu C. Snakes, shapes, and gradient vector flow[C]//Inter-national Conference on Image Processing. 2002, 9(2): 17-820.

* Gradient Vector Flow (GVF) Active Contour Toolbox by Chenyang Xu and Jerry Prince
