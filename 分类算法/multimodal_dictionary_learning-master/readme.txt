The Script is for multimodal task-driven classification using l_{12} prior (joint sparsity).

It performs dictionary learning (unsupervised and supervised) on training data. The optimal sparse codes generated are used as features for multimodal classification using quadratic loss function. It is straight forward to extend the code to cover other convex cost functions such as logistic regression. For more
information see the paper below:

Multimodal Task-Driven Dictionary Learning for Image Classification
Soheil Bahrampour, Nasser M. Nasrabadi, Asok Ray, W. Kenneth Jenkins
IEEE Transactions on Image Processing, vol.PP, no.99, pp.1-1
doi: 10.1109/TIP.2015.2496275

http://arxiv.org/abs/1502.01094

Please cite above paper if you use this code.

The joint sparse coding is solved using ADMM algorithm. The algorithm is implemented in c to gain speed advantage and is linked hear using a mex file. Of course, one can use other optimization algorithms instead of ADMM. The mex file is compiled for 64 system with a custom architecture and it is not guaranteed that it can be used efficiently with other systems.

Use the ClassificationMultiClassDecFusJoint.m file as the entry point.