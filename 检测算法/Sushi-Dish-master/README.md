# Sushi-Dish

In conveyor belt sushi restaurants, billing is a burdened job because one has to manually count the number of dishes and identify the color of them to calculate the price. In a busy situation, there can be a mistake that customers are overcharged or undercharged. To deal with this problem, we developed a method that automatically identifies the color of dishes and calculate the total price using real images. Our method consists of ellipse fitting and convolutional neural network. It achieves ellipse detection precision 85% and recall 96% and classification accuracy 92%.

#### Implementation

Implementation details are in the paper :  
*Sushi Dish - Object detection and classification from real images*

#### Demo

After modifying the path setting in demo script *'runDemo'*, you can run demo program using this script.

* Installation instructions for MatConvNet: http://www.vlfeat.org/matconvnet/
* Pre-trained CNN: `imdb.mat`: https://goo.gl/gI5FPQ, `net-epoch-57.mat`: https://goo.gl/gdlm10
