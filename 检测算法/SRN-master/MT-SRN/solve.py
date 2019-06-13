from __future__ import division
import numpy as np
import sys
caffe_root = '../../' 
sys.path.insert(0, caffe_root + 'python')
import caffe

# make a bilinear interpolation kernel
# credit @longjon
def upsample_filt(size):
    factor = (size + 1) // 2
    if size % 2 == 1:
        center = factor - 1
    else:
        center = factor - 0.5
    og = np.ogrid[:size, :size]
    return (1 - abs(og[0] - center) / factor) * \
           (1 - abs(og[1] - center) / factor)

# set parameters s.t. deconvolutional layers compute bilinear interpolation
# N.B. this is for deconvolution without groups
def interp_surgery(net, layers):
    for l in layers:
        m, k, h, w = net.params[l][0].data.shape
        if m != k:
            print 'input + output channels need to be the same'
            raise
        if h != w:
            print 'filters need to be square'
            raise
        filt = upsample_filt(h)
        net.params[l][0].data[range(m), range(k), :, :] = filt

# base net -- follow the editing model parameters example to make
# a fully convolutional VGG16 net.
# http://nbviewer.ipython.org/github/BVLC/caffe/blob/master/examples/net_surgery.ipynb


# init
caffe.set_mode_gpu()
caffe.set_device(0)

## stage 1 for contour
solver = caffe.SGDSolver('solver_contour_stage1.prototxt')
interp_layers = [k for k in solver.net.params.keys() if 'up' in k]
interp_surgery(solver.net, interp_layers)
base_weights = '5stage-vgg.caffemodel'
solver.net.copy_from(base_weights)
solver.step(8000)

## stage 2 for symmetry
solver = caffe.SGDSolver('solver_symmetry_stage1.prototxt')
interp_layers = [k for k in solver.net.params.keys() if 'up' in k]
interp_surgery(solver.net, interp_layers)
base_weights = 'stage1_srn_contour_iter_8000.caffemodel'
solver.net.copy_from(base_weights)
solver.step(8000)

## stage 3 for contour
solver = caffe.SGDSolver('solver_contour_stage2.prototxt')
interp_layers = [k for k in solver.net.params.keys() if 'up' in k]
interp_surgery(solver.net, interp_layers)
base_weights = 'stage1_srn_contour_iter_8000.caffemodel'
base_weights1 = 'stage1_srn_symmetry_iter_8000.caffemodel'
solver.net.copy_from(base_weights)
solver.net.copy_from(base_weights1)
solver.step(6000)

## stage 4 for contour
solver = caffe.SGDSolver('solver_symmetry_stage2.prototxt')
interp_layers = [k for k in solver.net.params.keys() if 'up' in k]
interp_surgery(solver.net, interp_layers)
base_weights = 'stage1_srn_symmetry_iter_8000.caffemodel'
base_weights1 = 'stage2_srn_contour_iter_6000.caffemodel'
solver.net.copy_from(base_weights)
solver.net.copy_from(base_weights1)
solver.step(6000)

## stage 5 for contour
solver = caffe.SGDSolver('solver_contour_stage3.prototxt')
interp_layers = [k for k in solver.net.params.keys() if 'up' in k]
interp_surgery(solver.net, interp_layers)
base_weights = 'stage2_srn_contour_iter_6000.caffemodel'
base_weights1 = 'stage2_srn_symmetry_iter_6000.caffemodel'
solver.net.copy_from(base_weights)
solver.net.copy_from(base_weights1)
solver.step(4000)

## stage 6 for contour
solver = caffe.SGDSolver('solver_symmetry_stage3.prototxt')
interp_layers = [k for k in solver.net.params.keys() if 'up' in k]
interp_surgery(solver.net, interp_layers)
base_weights = 'stage2_srn_symmetry_iter_6000.caffemodel'
base_weights1 = 'stage3_srn_contour_iter_4000.caffemodel'
solver.net.copy_from(base_weights)
solver.net.copy_from(base_weights1)
solver.step(4000)

## stage 7 for contour
solver = caffe.SGDSolver('solver_contour_stage4.prototxt')
interp_layers = [k for k in solver.net.params.keys() if 'up' in k]
interp_surgery(solver.net, interp_layers)
base_weights = 'stage3_srn_contour_iter_4000.caffemodel'
base_weights1 = 'stage3_srn_symmetry_iter_4000.caffemodel'
solver.net.copy_from(base_weights)
solver.net.copy_from(base_weights1)
solver.step(2000)

## stage 8 for contour
solver = caffe.SGDSolver('solver_symmetry_stage4.prototxt')
interp_layers = [k for k in solver.net.params.keys() if 'up' in k]
interp_surgery(solver.net, interp_layers)
base_weights = 'stage3_srn_symmetry_iter_4000.caffemodel'
base_weights1 = 'stage4_srn_contour_iter_2000.caffemodel'
solver.net.copy_from(base_weights)
solver.net.copy_from(base_weights1)
solver.step(2000)

## stage 9 for contour
solver = caffe.SGDSolver('solver_contour_stage5.prototxt')
interp_layers = [k for k in solver.net.params.keys() if 'up' in k]
interp_surgery(solver.net, interp_layers)
base_weights = 'stage4_srn_contour_iter_2000.caffemodel'
base_weights1 = 'stage4_srn_symmetry_iter_2000.caffemodel'
solver.net.copy_from(base_weights)
solver.net.copy_from(base_weights1)
solver.step(1000)

## stage 10 for contour
solver = caffe.SGDSolver('solver_symmetry_stage5.prototxt')
interp_layers = [k for k in solver.net.params.keys() if 'up' in k]
interp_surgery(solver.net, interp_layers)
base_weights = 'stage4_srn_symmetry_iter_2000.caffemodel'
base_weights1 = 'stage5_srn_contour_iter_1000.caffemodel'
solver.net.copy_from(base_weights)
solver.net.copy_from(base_weights1)
solver.step(1000)