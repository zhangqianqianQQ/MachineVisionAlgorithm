# Supervised-Spectral-spatial-Hyperspectral-Image-Classification-with-Weighted-Markov-Random-Fields

This paper presents a new approach for hyperspectral image classification exploiting spectral-spatial information. Under the maximum a posteriori framework, we propose a supervised classification model which includes a spectral data fidelity term and a spatially adaptive Markov random field (MRF) prior in the hidden field. The data fidelity term adopted in this paper is learned from the sparse multinomial logistic regression (SMLR) classifier, while the spatially adaptive MRF prior is modeled by a spatially adaptive total variation (SpATV) regularization to enforce a spatially smooth classifier. To further improve the classification accuracy, the true labels of training samples are fixed as an additional constraint in the proposed model. Thus, our model takes full advantage of exploiting the spatial and contextual information present in the hyperspectral image. An efficient hyperspectral image classification algorithm, named SMLR-SpATV, is then developed to solve the final proposed model using the alternating direction method of multipliers. Experimental results on real hyperspectral data sets demonstrate that the proposed approach outperforms many state-of-the-art methods in terms of the overall accuracy, average accuracy, and kappa (k) statistic.

The code is only for academical purpose, and please cite the paper:

[1] Le Sun, Zebin Wu, Jianjun Liu, Liang Xiao, Zhihui Wei, " Supervised Spectral-spatial Hyperspectral Image Classification with Weighted Markov Random Fields ",  IEEE Transactions on Geoscience and Remote Sensing, March 2015, Vol. 53(3):1490-1503. 

or cite by bibTex

@article{sun2015supervised,
  title={Supervised spectral--spatial hyperspectral image classification with weighted Markov random fields},
  author={Sun, Le and Wu, Zebin and Liu, Jianjun and Xiao, Liang and Wei, Zhihui},
  journal={IEEE Transactions on Geoscience and Remote Sensing},
  volume={53},
  number={3},
  pages={1490--1503},
  year={2015},
  publisher={IEEE}
  }
